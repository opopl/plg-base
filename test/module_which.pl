#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Module::Which qw/ which /;

my $result = which('Module::Which', 'YAML', 'XML::', 'DBI', 'DBD::');
while (my ($module, $info) = each %$result) {
	print "$module:\n";
	print "  version: $info->{version}\n" if $info->{version};
	print "     path: $info->{path}\n"    if $info->{path}; 
}
