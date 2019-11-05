#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Tk;

use FindBin qw($Bin);
use lib "$Bin/../perl/lib";

package D;

use base qw(Plg::Base::Dialog);

package main;

D->new->run;

