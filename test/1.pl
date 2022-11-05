#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new
);

use Capture::Tiny qw(capture);

use Base::Git qw(
    git_add
    git_rm
    git_mv
    git_has
);

my $b = '22';
eval { 
$b++;
};

#print $b;

my $c = undef;
print Dumper(ref $c) . "\n";
