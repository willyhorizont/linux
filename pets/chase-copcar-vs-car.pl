#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

my $TOTAL_SPACES = 24;

my $space1 = int(rand($TOTAL_SPACES + 1));
my $remaining = $TOTAL_SPACES - $space1;

my $space2 = int(rand($remaining + 1));
my $space3 = $remaining - $space2;

my $pad1 = " " x $space1;
my $pad2 = " " x $space2;
my $pad3 = " " x $space3;

my $moving_part = $pad1 . "🚗💨" . $pad2 . "🚓💨" . $pad3;

my $final_result = "  " . $moving_part . " ";

print "$final_result";
