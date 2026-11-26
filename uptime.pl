#!/usr/bin/env perl
use strict;
use warnings;

my $CMD_CLICK = "";
my $mode = "tint2";
my $pref = "[";
my $suff = "]";
my $use_pango = 0;

for (my $i = 0; $i <= $#ARGV; $i++) {
    if ($ARGV[$i] eq "--mode" && $i + 1 <= $#ARGV) {
        my $m = $ARGV[++$i];
        $mode = $m if ($m eq "tint2" || $m eq "xfce4-panel");
    } elsif ($ARGV[$i] eq "--pref" && $i + 1 <= $#ARGV) {
        $pref = $ARGV[++$i];
    } elsif ($ARGV[$i] eq "--suff" && $i + 1 <= $#ARGV) {
        $suff = $ARGV[++$i];
    } elsif ($ARGV[$i] eq "--pango") {
        $use_pango = 1;
    }
}

if (open(my $fh, "<", "/proc/uptime")) {
    my $line = <$fh>;
    close($fh);
    if ($line && $line =~ /^([0-9.]+)/) {
        my $secs = $1;
        my $hours = int($secs / 3600);
        my $minutes = int(($secs % 3600) / 60);

        if ($hours > 9999999999999) {
            $hours = 9999999999999;
        }

        my $k_lbl = "uptime ";
        my $out_str = "";

        if ($hours < 1000) {
            my $v_hrs = sprintf("%3d", $hours);
            my $v_min = sprintf("%2d", $minutes);
            if ($use_pango) {
                $out_str .= "<span background='#000000' foreground='#00ADD8'>$pref</span>";
                $out_str .= "<span background='#000000' foreground='#FF1493'>$k_lbl</span>";
                $out_str .= "<span background='#000000' foreground='#CCFF00'>$v_hrs</span>";
                $out_str .= "<span background='#000000' foreground='#FF1493'>hours </span>";
                $out_str .= "<span background='#000000' foreground='#CCFF00'>$v_min</span>";
                $out_str .= "<span background='#000000' foreground='#FF1493'>minutes</span>";
                $out_str .= "<span background='#000000' foreground='#00ADD8'>$suff</span>";
            } else {
                $out_str = "${pref}${k_lbl}${v_hrs}hours ${v_min}minutes${suff}";
            }
        } else {
            my $v_hrs = sprintf("%13d", $hours);
            if ($use_pango) {
                $out_str .= "<span background='#000000' foreground='#00ADD8'>$pref</span>";
                $out_str .= "<span background='#000000' foreground='#FF1493'>$k_lbl</span>";
                $out_str .= "<span background='#000000' foreground='#CCFF00'>$v_hrs</span>";
                $out_str .= "<span background='#000000' foreground='#FF1493'>hours</span>";
                $out_str .= "<span background='#000000' foreground='#00ADD8'>$suff</span>";
            } else {
                $out_str = "${pref}${k_lbl}${v_hrs}hours${suff}";
            }
        }

        my $tooltip_txt = "";

        if ($mode eq "xfce4-panel") {
            print "<txt>$out_str</txt>\n";
            print "<txtclick>$CMD_CLICK</txtclick>\n";
            print "<tool>$tooltip_txt</tool>\n";
        } else {
            print "$out_str\n";
            print STDERR "\x1b[2J$tooltip_txt";
        }
    }
}
