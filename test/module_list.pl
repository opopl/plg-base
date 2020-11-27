#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Module::List qw(list_modules);
 
my $id_modules = list_modules("File::", { list_modules => 1 });
print Dumper($id_modules) . "\n";
