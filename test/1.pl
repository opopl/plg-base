#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new
);

my @k = qw(a b c );
my %a = map { $_ => 2 } @k;

print Dumper(\%a) . "\n";
