#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Carp qw(croak);

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    dict_update
    dict_new

    list_exe_cb
    dict_exe_cb
);
use Cwd qw(getcwd);
use File::Find::Rule;

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
#my $a = 'a b c';
#print Dumper([split " " => $a ]) . "\n";
    #
#local $_ = '222';

#sub r {
    #my ($sref) = @_;
    #local $_ = $$sref;

    #s/2/3/g;
    #$$sref = $_;
#}

#r(\$_);
#print Dumper($_) . "\n";

#0 && print 3;
    #

#my $rule = File::Find::Rule->new;
#my @bn;

#my @pall = $rule
        #->name('*.pl')
        #->maxdepth(1)
        #->exec(sub { 
            #my ($shortname, $path, $fullname) = @_;
            #push @bn, $shortname;
            ##push @bn, $path;
            #push @bn, $fullname;
        #})
        #->in(getcwd())
        #;

##print Dumper(\@pall) . "\n";
#print Dumper(\@bn) . "\n";
		#
#my $a = {};
#$a->{b}++;
##print Dumper(4 % 4) . "\n";

#3 =~ /2/;
#3 =~ /(?<aa>2)/;
#print Dumper(\%+) . "\n";
#print Dumper(\@+) . "\n";
		#
my $a = 1 && 3;
print Dumper($a) . "\n";
eval { die };

print qq{$@} . "\n";
print qq{bb} . "\n";
