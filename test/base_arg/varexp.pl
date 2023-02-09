#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
	hash_inject
	hash_apply

	varexp
	varval
);

my $vars = {
    # a.b => c
    a => { b => 'c' },
    # d.e => f
    d => { e => 'f' },
    # two.plus.three => five
    two => {
        value => 2,
        plus => { three => 5 },
        minus => { two => 0 },
    },
    one => { value => 1 },
    ten => { value => 10 },
};

my $dict = { 
#    five => { 
        #value => '@ifvar{two.plus.three}{@val}',
        #plus => {
            #three => '@var{two.value}+@var{two.value}+@var{two.value}+@var{one.value}',
            #ten => '@var{two.plus.three}@ifvar{ten.value}{+@val}'
        #}
    #},
    #two  => { value => '@var{two.value}' },

    #null => '@ifvar{two.minus.two} other',
    #null_shift => '  @ifvar{two.minus.two} other',

    twenty  => { 
        value => '@ifvar{ten.value}{@val}+@ifvar{ten.value}{@val}',
        two => {}
    },
};

varexp($dict, $vars, { pref => '@' });
