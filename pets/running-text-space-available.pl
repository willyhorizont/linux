#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

my $CORE_TEXT = "SPACE AVAILABLE SPACE AVAILABLE ";
my $CORE_LEN  = length($CORE_TEXT);

my $uptime = 0;
if (open(my $fh, '<', '/proc/uptime')) {
    my $ln = <$fh>;
    close($fh);
    if ($ln =~ /^(\d+)/) {
        $uptime = int($1) % $CORE_LEN;
    }
}

my $long_txt   = $CORE_TEXT . $CORE_TEXT;
my $moving_part = substr($long_txt, $uptime, 32);
my $final_result = "  " . $moving_part . " ";

print "$final_result";
