#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

#local $_ = 'Mac::NA_MS_asdsad';
#print 'a' if /^(\w+)::(\w+)_MS(?:|_(\w+))$/;
#
#local $_ = ' ig@';
#print $1 if /^\s*(\w+)/;


my $b = { 2 => undef, 1 => 1 };


my $c = $b->{1};
$b->{1} = 2;

#print $c;

sub a {
	my ($a,$b ) = @_;
return Dumper([ $a, $b]);
}

local $_= '@fbicon{2}{w} sdfsfsdf @fbicon{3} sfdsf';
s/\@fbicon\{(\d+)\}(?:\{(\w+)\}|)/a($1,$2)/eg;

print;
