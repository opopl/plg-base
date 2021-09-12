#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Regexp::Common qw(URI);

local $_ = 'http://bit.ly/3gb7wXA,; sdf ';

print Dumper([ /$RE{URI}{HTTP}/g ]);
#print Dumper({ %$RE{URI} }) . "\n";
#
use Text::Sprintf::Named qw(named_sprintf);
 
# Prints "Hello Sophie!" (and a newline).
print named_sprintf("Hello %(name)s!\n", { name => 'Sophie' });

