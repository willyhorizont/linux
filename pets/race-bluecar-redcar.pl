#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

my $unit1 = "🚗💨";
my $unit2 = "🚙💨";

my $TOTAL_SPACES = 24;

my $space1 = int(rand($TOTAL_SPACES + 1));
my $remaining = $TOTAL_SPACES - $space1;

my $space2 = int(rand($remaining + 1));
my $space3 = $remaining - $space2;

my $pad1 = " " x $space1;
my $pad2 = " " x $space2;
my $pad3 = " " x $space3;

my $moving_part = "";
if (rand(100) < 50) {
    $moving_part = $pad1 . $unit1 . $pad2 . $unit2 . $pad3;
} else {
    $moving_part = $pad1 . $unit2 . $pad2 . $unit1 . $pad3;
}

my $final_result = "  " . $moving_part . " ";

print "$final_result";
