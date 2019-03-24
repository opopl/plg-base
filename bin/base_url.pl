#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::URL qw(:funcs :vars);

my $url = 'a/b';

print Dumper [ $url, url_normalize($url) ];
