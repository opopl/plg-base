#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use FindBin qw($Bin $Script);

use lib "$Bin/../lib";

use Base::App::Grep;

Base::App::Grep->new->run;

