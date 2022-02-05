#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(dict_update);


my %a;
$a{1} .= '22';
print Dumper(\%a) . "\n";
