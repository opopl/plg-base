#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Module::Which qw/ which /;

my @a; 
	push @a,
	('File::Slurp', )
	;

my $result = which(@a);
while (my ($module, $info) = each %$result) {
	print "$module:\n";
	print "  version: $info->{version}\n" if $info->{version};
	print "     path: $info->{path}\n"    if $info->{path}; 
}
