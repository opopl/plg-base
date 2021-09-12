#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

binmode STDOUT,':encoding(utf8)';

use Data::Dumper qw(Dumper);

#local $_ = 'Mac::NA_MS_asdsad';
#print 'a' if /^(\w+)::(\w+)_MS(?:|_(\w+))$/;
#
#local $_ = ' ig@';
#print $1 if /^\s*(\w+)/;
#
local $_ = '@a b';
my @b = ( m/^\s*(?<pref>@|)(?<key>\w+)\s+(?<value>\w+)/g );

print Dumper(\@b) . "\n";
print Dumper(\%+) . "\n";

print "\N{SMILING FACE WITH OPEN MOUTH}";
print "\N{SMILING FACE WITH SUNGLASSES}";

print "\N{FULL MOON WITH FACE}";
