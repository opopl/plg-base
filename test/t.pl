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

#foreach my $x (split(":" => $s)) {
	#print Dumper([ split('\|' => $x) ] ) . "\n";
#}

#my @a = (1,2,);
#my $t =(@a > 1) ? 1 : 0;
#print $t;

#sub a {
	#my ($b) = @_;

	##$b->
#}
#my $a = { 1 => 2 };
#my $b = { %$a, 1 => 3, 1 => 4 };
#print Dumper($b) . "\n";
#my @a = ( 1 .. 1 );
#print Dumper($#a) . "\n";

	#print Dumper( (1 == 2) ? 1 : 0	) . "\n";

my $a = {
	last => 2,
	if => 2,
};
print Dumper($a) . "\n";
