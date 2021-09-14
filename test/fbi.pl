#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

binmode STDOUT,':encoding(utf8)';

use Plg::Projs::Tex qw(
  texify
  %fbicons
  fbicon_igg
);

use Data::Dumper qw(Dumper);

#local $_ = 'Mac::NA_MS_asdsad';
#print 'a' if /^(\w+)::(\w+)_MS(?:|_(\w+))$/;
#
#local $_ = ' ig@';
#print $1 if /^\s*(\w+)/;
#
local $_ = '🤬🤯🙂😡🙁';

my @utf = keys %fbicons;
my @fbi;
while(@utf){
  my $k = shift @utf;

  #while(/($k+)/){
  #}
  s/($k+)/fbicon_igg($1)/ge;
}

print ;

