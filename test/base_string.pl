#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::String qw(
	str_split
);

my $d = { a => {} };
my $aa = $d->{a};

$aa->{2} = 2;

my @a = ( 1 .. 10 ); 
my $i;
my @b = map { BEGIN { $i = 0 }; $i++; $i } @a;

print Dumper(\@b) . "\n";
