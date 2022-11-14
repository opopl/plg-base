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
use Plg::Projs::Tex qw(
    texify
    texify_ref
    $texify_in
    $texify_out
);


use Base::Git qw(
    git_add
    git_rm
    git_mv
    git_has
);

my $a = {};
my $b = $a->{1}->{2};

print Dumper(%{$b || {}}) . "\n";

my @a = 1;
print Dumper(\@a) . "\n";

