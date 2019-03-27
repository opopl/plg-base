#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::XML qw(
	pl_to_xml
	xml_pretty
);

my $a = [ 0 .. 10 ];

my $xml = pl_to_xml($a);

print $xml . "\n";
