#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
	hash_apply
);

my $a = {
   # a => 1,
	#b => 2,
	#d => 4,
	#h => { w => 10 },
};
my $b = {
	a => 11,
	b => 22,
	c => 333,
	h => { w => { z => 100 }, v => 20 },
};

hash_apply($a, $b);

print Dumper($a) . "\n";
