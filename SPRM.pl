#!/usr/bin/env perl
use strict;
use warnings;
use Time::HiRes qw(time);

my $NET_INTRF = "wlp3s0";
my $CACHE_FILE = "/tmp/sprm_perl_cache.json";

sub pad {
    my ($str, $len) = @_;
    return sprintf("%*s", $len, $str);
}

sub fmt {
    my ($bytesps) = @_;
    if ($bytesps <= 0) {
        return "      0B/s";
    }
    my @units = ("B/s", "KB/s", "MB/s");
    my $i = 0;
    my $v = $bytesps;
    while ($v >= 1024 && $i < $#units) {
        $v /= 1024;
        $i++;
    }
    
    my $num_str = ($i == 0) ? sprintf("%.3f", $v) : sprintf("%.2f", $v);
    my ($f_p, $b_p) = split(/\./, $num_str);
    
    if (length($f_p) > 3) {
        return "999999GB/s";
    }
    
    $f_p = pad($f_p, 3);
    return "$f_p.$b_p$units[$i]";
}

my $temp = 0.0;
if (open(my $fh, "-|", "sensors 2>/dev/null")) {
    while (<$fh>) {
        if (/Tctl|Tdie|Edge|Core/) {
            if (/ \+?(\d+\.\d+)°C/) {
                $temp = $1;
                last;
            }
        }
    }
    close($fh);
}

my @cpu_parts = (0) * 7;
if (open(my $fh, "<", "/proc/stat")) {
    while (<$fh>) {
        if (/^cpu /) {
            @cpu_parts = (split)[1..7];
            last;
        }
    }
    close($fh);
}

my $gpu = 0.0;
if (open(my $fh, "<", "/sys/class/drm/card0/device/gpu_busy_percent")) {
    $gpu = <$fh>;
    chomp($gpu);
    close($fh);
}

my ($mem_t, $mem_a) = (0, 0);
if (open(my $fh, "<", "/proc/meminfo")) {
    while (<$fh>) {
        if (/MemTotal:\s+(\d+)/) { $mem_t = $1; }
        elsif (/MemAvailable:\s+(\d+)/) { $mem_a = $1; }
    }
    close($fh);
}
my $ram_used = ($mem_t - $mem_a) / 1024 / 1024;
my $ram_tot = $mem_t / 1024 / 1024;

my ($d_free_GB, $d_tot_GB) = (0.0, 0.0);
if (open(my $fh, "-|", "df -B1 / 2>/dev/null")) {
    while (<$fh>) {
        next if $. == 1;
        my @p = split;
        $d_tot_GB = $p[1] / 1e9;
        $d_free_GB = $p[3] / 1e9;
    }
    close($fh);
}

my ($cur_d_r, $cur_d_w) = (0, 0);
if (open(my $fh, "<", "/proc/diskstats")) {
    while (<$fh>) {
        my @p = split;
        if ($p[2] =~ /sd|nvme/) {
            $cur_d_r += $p[5];
            $cur_d_w += $p[9];
        }
    }
    close($fh);
}
$cur_d_r *= 512;
$cur_d_w *= 512;

my ($cur_net_down, $cur_net_up) = (0, 0);
if (open(my $fh, "<", "/proc/net/dev")) {
    while (<$fh>) {
        if (/$NET_INTRF/) {
            my @p = split(/[:\s]+/);
            shift @p if $p[0] eq '';
            $cur_net_down = $p[1];
            $cur_net_up = $p[9];
            last;
        }
    }
    close($fh);
}

my $now_time = time();
my %old;

if (-f $CACHE_FILE) {
    if (open(my $fh, "<", $CACHE_FILE)) {
        my $ctx = <$fh>;
        close($fh);
        if ($ctx && $ctx =~ /\{.*\}/) {
            if ($ctx =~ /"time":(\d+\.?\d*)/) { $old{time} = $1; }
            if ($ctx =~ /"d_r":(\d+)/) { $old{d_r} = $1; }
            if ($ctx =~ /"d_w":(\d+)/) { $old{d_w} = $1; }
            if ($ctx =~ /"n_d":(\d+)/) { $old{n_d} = $1; }
            if ($ctx =~ /"n_u":(\d+)/) { $old{n_u} = $1; }
            if ($ctx =~ /"cpu":\[(.*?)\]/) {
                my @c = split(/,/, $1);
                $old{cpu} = \@c;
            }
        }
    }
}

my $time_d = $now_time - ($old{time} || ($now_time - 2.0));
$time_d = 2.0 if $time_d <= 0;

my ($user, $nice, $system, $idle, $iowait, $irq, $softirq) = @cpu_parts;
my @old_cpu = $old{cpu} ? @{$old{cpu}} : (0) * 7;

my $old_idle = $old_cpu[3] + $old_cpu[4];
my $new_idle = $idle + $iowait;
my $old_non_idle = $old_cpu[0] + $old_cpu[1] + $old_cpu[2] + $old_cpu[5] + $old_cpu[6];
my $new_non_idle = $user + $nice + $system + $irq + $softirq;

my $tot_old = $old_idle + $old_non_idle;
my $tot_new = $new_idle + $new_non_idle;
my $tot_delta = $tot_new - $tot_old;
my $idle_delta = $new_idle - $old_idle;

my $cpu_pcent = 0.0;
if ($tot_delta > 0) {
    $cpu_pcent = (($tot_delta - $idle_delta) / $tot_delta) * 100;
}
my $cpu_fmt = pad(sprintf("%.1f", $cpu_pcent), 4);

my $r_rt = exists $old{d_r} ? (($cur_d_r - $old{d_r}) / $time_d) : 0;
my $w_rt = exists $old{d_w} ? (($cur_d_w - $old{d_w}) / $time_d) : 0;
my $d_rt = exists $old{n_d} ? (($cur_net_down - $old{n_d}) / $time_d) : 0;
my $u_rt = exists $old{n_u} ? (($cur_net_up - $old{n_u}) / $time_d) : 0;

$r_rt = 0 if $r_rt < 0; $w_rt = 0 if $w_rt < 0;
$d_rt = 0 if $d_rt < 0; $u_rt = 0 if $u_rt < 0;

if (open(my $fh, ">", $CACHE_FILE)) {
    my $cpu = join(",", @cpu_parts);
    print $fh "{\"time\":$now_time,\"cpu\":[$cpu],\"d_r\":$cur_d_r,\"d_w\":$cur_d_w,\"n_d\":$cur_net_down,\"n_u\":$cur_net_up}";
    close($fh);
}

my $temp_str = ($temp >= 100.0) ? "9999" : sprintf("%.1f", $temp);
my $gpu_fmt = pad(sprintf("%.1f", $gpu), 4);
my $ram_used_str = pad(sprintf("%.2f", $ram_used), 5);
my $ram_tot_str = sprintf("%.2f", $ram_tot);
my $d_free_str = sprintf("%.2f", $d_free_GB);
my $d_tot_str = sprintf("%.2f", $d_tot_GB);

my $f_r = fmt($r_rt); my $f_w = fmt($w_rt);
my $f_d = fmt($d_rt); my $f_u = fmt($u_rt);

my $out_t = ($temp_str eq "9999") ? "9999°C" : "${temp_str}°C";
my $out_r = ($f_r =~ /999999/) ? "999999GB/s" : $f_r;
my $out_w = ($f_w =~ /999999/) ? "999999GB/s" : $f_w;
my $out_d = ($f_d =~ /999999/) ? "999999GB/s" : $f_d;
my $out_u = ($f_u =~ /999999/) ? "999999GB/s" : $f_u;

print " T $out_t | C $cpu_fmt% | G $gpu_fmt% | M $ram_used_str/${ram_tot_str}GB | D $d_free_str/${d_tot_str}GB | R $out_r | W $out_w | ▼ $out_d | ▲ $out_u |";
