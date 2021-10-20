#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

my $args = { 
	1 => 2,
	2 => 3
};

my $a = {
	1 => 'tree',
	map { $_ => $args->{$_} } qw(a b 1) 
};

print Dumper($a) . "\n";
