#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::Data::Dmap;
#use Data::Dmap;
 
my $foo = {
    cars => [ 'ford', 'opel', 'BMW' ],
    birds => [ 'cuckatoo', 'ostrich', 'frigate' ],
    handler => sub { print "barf\n" }
};
 
# This removes all keys named 'cars'    
my($bar) = dmap { delete $_->{cars} if ref eq 'HASH'; $_ } $foo;
 
# This replaces arrays with the number of elements they contains
my($other) = dmap { $_ = scalar @$_ if ref eq 'ARRAY'; $_ } $foo;
 
use Data::Dumper;
print Dumper $other;
#
# Prints
# {
#    birds => 3,
#    handler => sub { "DUMMY" }
# }
# (Data::Dumper doesn't dump subs)
 
$other->{handler}->();
 #Prints
 #barf
