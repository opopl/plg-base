#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Algorithm::Permute;

my @array = 'a'..'d';
my $p_iterator = Algorithm::Permute->new ( \@array );

use Algorithm::Permute;

my @array = 'a'..'d';
my $p_iterator = Algorithm::Permute->new ( \@array );

my $j = 1;
while (my @perm = $p_iterator->next) {
   print "$j next permutation: (@perm)\n";
   $j++;
}
