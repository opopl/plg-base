#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Base::String qw(str_env);

print str_env('$perlgem/a/$perlgem') . "\n";
