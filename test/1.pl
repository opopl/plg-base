#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(dict_update);

#my $a = undef if 0 || 1;

#my @b;
#push @b, 0 || undef || 2;
#print Dumper(\@b) . "\n";

#my $a = { a_2 => 'a'} ;
#print Dumper($a) . "\n";

#my $a = "\N{CITYSCAPE}\N{VARIATION SELECTOR-16}";
#print qq{$a} . "\n";
#print ref undef;
#
print undef // 2;

my $d = { a => { 1 => 2 } };
my $u = { a => { 2 => 3 } };

dict_update($d, $u);
print Dumper($d) . "\n";
