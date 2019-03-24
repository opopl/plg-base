#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::URL qw(:funcs :vars);

my $urls = [];

push @$urls, 
   # '#a',
	#'a/b',
	#'a/b/c',
	#'a',
	#'/a',
	'http:///a',
	'http://a',
	;

foreach my $url (@$urls) {
	print Dumper [ $url, url_type($url), url_normalize($url,{ type => 'external'}) ];
}

