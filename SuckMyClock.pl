#!/usr/bin/env perl
use strict;
use warnings;
use Time::Piece;

my $t = localtime;

my $month_num = $t->strftime('%m');
my $day_num = $t->strftime('%d');
my $total_days = $t->month_last_day;
my $date_string = $t->strftime('%a, %d %b %Y');
my $time_24 = $t->strftime('%H:%M:%S');
my $time_12 = $t->strftime('%I:%M:%S %p');

my $simple_clock = "| $month_num/12 months | $day_num/$total_days days | $date_string | $time_24 | $time_12 ";

print "$simple_clock\n";
