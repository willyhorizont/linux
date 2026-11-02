#!/usr/bin/env perl
use strict;
use warnings;

my $pref = "";
my $suff = " |";
my $use_pango = 0;

for (my $i = 0; $i <= $#ARGV; $i++) {
    if ($ARGV[$i] eq "--pref" && $i + 1 <= $#ARGV) {
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

        my $k_lbl = " uptime ";

        if ($hours < 1000) {
            my $v_hrs = sprintf("%3d", $hours);
            my $v_min = sprintf("%2d", $minutes);
            if ($use_pango) {
                print "<span background='#000000' foreground='#00ADD8'>$pref</span>" .
                      "<span background='#000000' foreground='#FF1493'>$k_lbl</span>" .
                      "<span background='#000000' foreground='#CCFF00'>$v_hrs</span>" .
                      "<span background='#000000' foreground='#FF1493'>hours </span>" .
                      "<span background='#000000' foreground='#CCFF00'>$v_min</span>" .
                      "<span background='#000000' foreground='#FF1493'>minutes</span>" .
                      "<span background='#000000' foreground='#00ADD8'>$suff</span>\n";
            } else {
                print "${pref}${k_lbl}${v_hrs}hours ${v_min}minutes${suff}\n";
            }
        } else {
            my $v_hrs = sprintf("%13d", $hours);
            if ($use_pango) {
                print "<span background='#000000' foreground='#00ADD8'>$pref</span>" .
                      "<span background='#000000' foreground='#FF1493'>$k_lbl</span>" .
                      "<span background='#000000' foreground='#CCFF00'>$v_hrs</span>" .
                      "<span background='#000000' foreground='#FF1493'>hours</span>" .
                      "<span background='#000000' foreground='#00ADD8'>$suff</span>\n";
            } else {
                print "${pref}${k_lbl}${v_hrs}hours${suff}\n";
            }
        }
    }
}
