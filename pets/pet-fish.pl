#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

my $STATE_FILE = "/tmp/pet-fish-index.txt";

my $cur_frame = 0;
if (-e $STATE_FILE) {
    if (open(my $fh, '<', $STATE_FILE)) {
        my $saved = <$fh>;
        close($fh);
        chomp($saved);
        $cur_frame = int($saved || 0);
    }
}

my @frames = (
    "𓆟",
    "𓆞",
    "𓆝",
    "𓆞",
);

my $tot_frames = scalar(@frames);
my $moving_part = $frames[$cur_frame];
my $final_result = "  " . $moving_part . " ";
print "$final_result";

my $next_frame = ($cur_frame + 1) % $tot_frames;
if (open(my $fh, '>', $STATE_FILE)) {
    print $fh "$next_frame\n";
    close($fh);
}
