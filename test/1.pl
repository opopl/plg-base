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

#my $a = 0;
#my $b ||= $a ? 2 : 3;
#print Dumper($b) . "\n";

#print Dumper(3 % 2) . "\n";

#my $cmd = 'git ls aa';
#my @args;

#my ($stdout, $stderr, $exit) = capture {
  #system( $cmd, @args );
#};

my $a ||= 0 ? 2 : 3;
print qq{$a} . "\n";

#print Dumper(git_has('aa')) . "\n";
  #
#my $a = "1\n";
#print $a =~ /\n$/ ? 1 : 0;

#my $a=[1];
#$a->{2} = 3;
#print Dumper($a) . "\n";

#print $a && @$a ? 1 : 0;
#print 1 unless $a && grep { /^243$/ } @$a;
