#!/usr/bin/env perl
use strict;
use warnings;
use Time::Piece;

my $t = localtime;

my $month_num = $t->strftime('%m');
my $day_num   = $t->strftime('%d');
my $year      = $t->year;
my $month_int = $t->mon;

my $next_month = ($month_int == 12) ? 1 : $month_int + 1;
my $next_year  = ($month_int == 12) ? $year + 1 : $year;
my $first_of_next_month = Time::Piece->strptime("$next_year-$next_month-01 12:00:00", "%Y-%m-%d %H:%M:%S");
my $last_of_this_month  = $first_of_next_month - 86400;
my $total_days          = $last_of_this_month->mday;

my $date_string = $t->strftime('%a, %d %b %Y');
my $time_24     = $t->strftime('%H:%M:%S');
my $time_12     = $t->strftime('%I:%M:%S %p');

my $simple_clock = "| $month_num/12 months | $day_num/$total_days days | $date_string | $time_24 | $time_12 ";

print "$simple_clock\n";
