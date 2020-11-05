#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Scalar::Util qw(blessed);
use HTML::Work;

my $htw=HTML::Work->new;

print Dumper(blessed($htw)) . "\n";
print Dumper(blessed({})) . "\n";
print Dumper(blessed({ [] => $htw })) . "\n";
