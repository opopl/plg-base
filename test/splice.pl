#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

#my @a = ( 1 .. 20 );
#my @a = ( 1  );
#splice @a,10;
##print Dumper(\@a) . "\n";
#print Dumper($a[-1]) . "\n";

my $s = '1, 2,, ,1,0';

my @a = keys ( map { s/^\s*//g; s/\s*$//g; length $_ ? ( $_ => 1 ) : () } split ',' => $s );

print Dumper(\@a) . "\n";
