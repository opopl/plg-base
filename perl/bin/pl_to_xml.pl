#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::XML qw(
	pl_to_xml
	xml_pretty
);

my $h = { 
	a => 2,
	b => 3,
	c => [ 0 .. 1 ],
	d => [ 'aa', 'bb', 'cc' ],
	#b => { 2 => 3 },
};
my $a = [ 0 .. 2 ];

my $o = {listas => 'a', attr => [qw(a b)]};

my $o_h = $o;
my $o_a = $o;

my ($xml_a) = pl_to_xml($a,$o_a);
my ($xml_h) = pl_to_xml($h,$o_h);

print $xml_h . "\n";
#print $xml_h . "\n";
