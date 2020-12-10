#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Module::Loaded;

print Dumper(is_loaded('FindBin')) . "\n";
print Dumper(is_loaded('Data::Dumper')) . "\n";
