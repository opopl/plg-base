#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::XML qw(node_to_pl);
use XML::LibXML;

my @xml;

push @xml,
   # q{<?xml version="1.0" encoding="UTF-8"?>
	#<root>
	  #<siteid>php_net_constants</siteid>
	  #<sites>
		#<item siteid="php_net_constants">
		  #<url>https://secure.php.net/manual/en/language.constants.php</url>
		  #<base_url>https://secure.php.net/manual/en</base_url>
		  #<savedir>C:\saved\html\php_net_save\constants</savedir>
		#</item>
	  #</sites>
	#</root>
	#},
	q{<?xml version="1.0" encoding="UTF-8"?>
	<root>
	  <siteid>a</siteid>
	  <siteid>b</siteid>
	  <siteid a="c">c</siteid>
	</root>
	},
;

foreach my $xml (@xml) {
	my $prs = XML::LibXML->new(
		no_blanks => 1,
	);

	my $dom = $prs->load_xml(
		string => $xml,
	);
	my $root = $dom->documentElement;
	
	my $data = node_to_pl({ node => $dom });
	
	print Dumper($data);

}
