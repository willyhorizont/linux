#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use List::Util qw(shuffle);

binmode(STDOUT, ":utf8");

my $max_len = 30;

my @items = ("🐟", "🐠");

my $count = scalar(@items);

if ($count > $max_len) {
    @items = @items[0..31];
    $count = $max_len;
}

my $TOTAL_SPACES = $max_len - $count;
my @gaps = ();

for (my $i = 0; $i < $count; $i++) {
    push @gaps, int(rand($TOTAL_SPACES + 1));
}

@gaps = sort { $a <=> $b } @gaps;

my @pads = ();
my $last = 0;
foreach my $g (@gaps) {
    push @pads, " " x ($g - $last);
    $last = $g;
}
push @pads, " " x ($TOTAL_SPACES - $last);

my @shuffled = shuffle(@items);
my $moving_part = "";

for (my $i = 0; $i < $count; $i++) {
    $moving_part .= $pads[$i] . $shuffled[$i];
}
$moving_part .= $pads[$count];

my $final = "  " . $moving_part . " ";

print "$final";
