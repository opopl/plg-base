#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new
);


my $a = 1 unless (undef,undef);
print Dumper($a) . "\n";

my $b = {
	a_a => 1
};

print Dumper($b) . "\n";
