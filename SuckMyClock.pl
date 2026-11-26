#!/usr/bin/env perl
use strict;
use warnings;
use Time::Piece;

my $CMD_CLICK = 'lxterminal --geometry=88x28 --working-directory=$HOME -e calcurse';
my $mode = "tint2";
my $pref = "[";
my $suff = "]";
my $sep = " | ";
my $use_pango = 0;

for (my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] eq "--mode" && $i + 1 < @ARGV) {
        my $m = $ARGV[++$i];
        $mode = $m if ($m eq "tint2" || $m eq "xfce4-panel");
    } elsif ($ARGV[$i] eq "--pref" && $i + 1 < @ARGV) {
        $pref = $ARGV[++$i];
    } elsif ($ARGV[$i] eq "--suff" && $i + 1 < @ARGV) {
        $suff = $ARGV[++$i];
    } elsif ($ARGV[$i] eq "--sep" && $i + 1 < @ARGV) {
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
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$pref</span>";
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
    $out_string .= "<span background='#000000' foreground='#00ADD8'>$suff</span>";
} else {
    $out_string = "$pref$month_num/12 months$sep$day_num/$total_days days$sep$date_string$sep$time_24$sep$time_12 $am_pm_str$suff";
}

my $tooltip_txt = "SuckMyClock (My Suckless Clock) Perl version\n" .
                  "click to open calcurse\n";

if ($mode eq "xfce4-panel") {
    print "<txt>$out_string</txt>\n";
    print "<txtclick>$CMD_CLICK</txtclick>\n";
    print "<tool>$tooltip_txt</tool>\n";
} else {
    print "$out_string\n";
    print STDERR "\x1b[2J$tooltip_txt";
}
