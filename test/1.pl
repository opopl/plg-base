#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new
);

#my %a;
#$a{1} .= '22';

my $d = dict_new('a.b.c',{ 1  => 2 });

print Dumper($d) . "\n";
