#!/usr/bin/env perl
use strict;
use warnings;

my $CORE_TEXT = "SPACE AVAILABLE SPACE AVAILABLE ";
my $CORE_LEN  = length($CORE_TEXT);

my $pos = 0;
if (open(my $fh, '<', '/proc/uptime')) {
    my $ln = <$fh>;
    close($fh);
    if ($ln =~ /^(\d+)/) {
        $pos = $1 % $CORE_LEN;
    }
}

my $long_txt   = $CORE_TEXT . $CORE_TEXT;
my $moving_part = substr($long_txt, $pos, 32);
my $rr = "  " . $moving_part . " ";

print "$rr";
