#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

my $a = undef if 0 || 1;

my @b;
push @b, 0 || undef || 2;
print Dumper(\@b) . "\n";
