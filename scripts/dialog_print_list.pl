#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Tk;

use FindBin qw($Bin);
use lib "$Bin/../perl/lib";
use base qw(Plg::Base::Dialog);

