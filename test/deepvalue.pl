#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Deep::Hash::Utils qw(deepvalue);
use Data::Dumper qw(Dumper);

my $a = { 1 => 'one' };
my $b = { 1 => 'one', 0 => [], 2 => { 3 => { 4 => 'four'}}  };

my $r = deepvalue($b,2,3,4);

#print Dumper($b) . "\n";
print Dumper($r) . "\n";

