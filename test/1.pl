#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new
);

#local $_ = 'aa aa';
#my @a = (m/aa/g);
#print Dumper(\@a) . "\n";
my $a = 1 if 0;
my $cc = 1 if 0;
my $ccc = 1 if undef;
print Dumper($ccc) . "\n";
