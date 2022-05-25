#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new
);

my $a = 0;
my $b ||= $a ? 2 : 3;
print Dumper($b) . "\n";


