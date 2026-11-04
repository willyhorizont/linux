#!/usr/bin/env perl
use strict;
use warnings;
use Time::Piece;

my $pref = " ";
my $suff = " ";
my $sep = " | ";
my $use_pango = 0;

for (my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] eq "--pref") {
        $pref = $ARGV[++$i];
    } elsif ($ARGV[$i] eq "--suff") {
        $suff = $ARGV[++$i];
    } elsif ($ARGV[$i] eq "--sep") {
        $sep = $ARGV[++$i];
    } elsif ($ARGV[$i] eq "--pango") {
        $use_pango = 1;
    }
}

my $t = localtime;

my $month_num = $t->strftime('%m');
my $day_num = $t->strftime('%d');
my $total_days = $t->month_last_day;
my $date_string = $t->strftime('%a, %d %b %Y');
my $time_24 = $t->strftime('%H:%M:%S');
my $time_12 = $t->strftime('%I:%M:%S');
my $am_pm_str = $t->strftime('%p');

my $out_string = "";
if ($use_pango) {
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$pref</span>" if $pref ne "";
    $out_string .= "<span background='#000000' foreground='#CCFF00'>$month_num/12 </span>";
    $out_string .= "<span background='#000000' foreground='#FF1493'>months</span>";
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$sep</span>";
    $out_string .= "<span background='#000000' foreground='#CCFF00'>$day_num/$total_days </span>";
    $out_string .= "<span background='#000000' foreground='#FF1493'>days</span>";
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$sep</span>";
    $out_string .= "<span background='#000000' foreground='#CCFF00'>$date_string</span>";
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$sep</span>";
    $out_string .= "<span background='#000000' foreground='#CCFF00'>$time_24</span>";
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$sep</span>";
    $out_string .= "<span background='#000000' foreground='#CCFF00'>$time_12 </span>";
    $out_string .= "<span background='#000000' foreground='#FF1493'>$am_pm_str</span>";
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$suff</span>" if $suff ne "";
} else {
    $out_string = "$pref$month_num/12 months$sep$day_num/$total_days days$sep$date_string$sep$time_24$sep$time_12 $am_pm_str$suff";
}

print "$out_string\n";

print STDERR <<'EOF';
 SuckMyClock (My Suckless Clock) Perl version;
 click to open calcurse
EOF
