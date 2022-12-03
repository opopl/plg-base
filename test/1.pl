#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new

    list_exe_cb
    dict_exe_cb
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

#my $a = {};
#my $b = $a->{1}->{2};

#print Dumper(%{$b || {}}) . "\n";

#my @a = 1;
#print Dumper(\@a) . "\n";

#my @b = ( '1' , '2' );
#for(@b){
    #s/1//g;
#}
#print Dumper(\@b) . "\n";

#my $a = [ 'a' .. 'z' ];
#my $b = { 
    #a => $a,
    #b => '22',
    #c => { d => 'xx' },
#};
#list_exe_cb($a, sub { sprintf('aaa %s', shift); });
#print Dumper($a) . "\n";
#
#
#dict_exe_cb($b, sub { sprintf('aaa %s', shift); });
##print Dumper($b) . "\n";
my $a = 'a b c';
print Dumper([split " " => $a ]) . "\n";
