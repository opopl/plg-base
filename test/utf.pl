#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

my $a = {
    '🤦' => 1,
};

print Dumper($a) . "\n";
