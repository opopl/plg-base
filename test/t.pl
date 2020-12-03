#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

#my $b = 'a';
#my $a = {
	#1 => $b,
#};

#print $$a{1};

my $s = q{174056|1|1:167838|1|1};

foreach my $x (split(":" => $s)) {
	print Dumper([ split('\|' => $x) ] ) . "\n";
}

