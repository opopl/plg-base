#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

local $_ = 'Mac::NA_MS_asdsad';
print 'a' if /^(\w+)::(\w+)_MS(?:|_(\w+))$/;
