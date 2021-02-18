#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

# filtering function for the list of pickup_door_ids
#   does in-place filtering
sub filter {
    # input array to be filtered
    my $arr = shift;

    my %seen;
    @$arr = 
        # only-positive numbers
        grep { /^(\d+)$/ && int($_) }

        # unique, non-zero values
        grep { !$seen{$_}++ && $_  } 

        # for erroneous zeroes in the beginning, e.g. 001223
        map { s/^[0]*//g; $_ }

        # left/right trimming
        map { s/^\s*//g; s/\s*$//g; $_ }
        @$arr;
}
my @a =  split ',' => '11,11,22,11';

filter(\@a);
print Dumper(\@a) . "\n";

#my $b;
##$b++;
#print $b++ . "\n";
#print $b . "\n";
