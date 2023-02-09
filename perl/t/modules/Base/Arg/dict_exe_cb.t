
use strict;
use warnings;

use Test::More;
use Data::Dumper qw(Dumper);
use Clone qw(clone);

BEGIN {
    require_ok('Base::Arg');

    my @funcs = qw(
        dict_exe_cb
        varexp
        varval
    );
    use_ok('Base::Arg',@funcs);
}

sub t_vars {
    my ($zero) = @_;

    my $a_z = [( 'a' .. 'z' )];

    my $expected = {
        zero => {
          0 => {
            a => {
              'a' => $a_z,
              'b' => [],
              'c' => [
                       'section',
                       'section'
                     ]
            }
          },
          1 => {
            a => {
              'a' => $a_z,
              'b' => $a_z,
              'c' => [
                       'section',
                       'zzz',
                       'section'
                     ]
            }
          }
        }
    };

    my $vars = {
        sec => 'section',
        zero => $zero,
    };

    my $a = {
        a => [@$a_z],
        b => [ map { '$ifvar{zero} ' . $_ } @$a_z],
        c => [
           '$var{sec}',
           '$ifvar{zero} zzz',
           '$ifvar{sec} $var{sec}',
        ]
    };

    my $ax = dict_exe_cb(clone($a), {
        cb => sub { shift },
        cb_list => sub { varexp(shift, $vars); },
    });
    is_deeply($ax, $expected->{zero}->{$zero}->{a},'dict_exe_cb: cb_list => varexp, zero => ' . $zero);
}

sub t_varexp_1 {
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
        empty => '',
        zero => 0,
        string_zero => '0',
    };

    my $dict = {
        five => {
            value => '@ifvar{two.plus.three}{@val}',
            plus => {
                three => '@var{two.value}+@var{two.value}+@var{two.value}+@var{one.value}',
                ten => '@var{two.plus.three}@ifvar{ten.value}{+@val}'
            }
        },
        two  => { value => '@var{two.value}' },
        twenty  => {
            value => '@ifvar{ten.value}{@val}+@ifvar{ten.value}{@val}',
            two => {
                value => '@ifvar{ten.value}{@val}+@ifvar{ten.value}{@val}+@ifvar{two.value}{@val}',
            }
        },

        null => '@ifvar{two.minus.two} other',
        null_shift => '  @ifvar{two.minus.two} other',

        empty => '@var{empty}@ifvar{empty}{non empty}',
        null_if_empty       => '@ifvar{empty} aaa',
        null_if_empty_shift => '  @ifvar{empty} aaa',
        null_if_empty_shift_then  => '  @ifvar{empty}{then} aaa',

        null_if_zero       => '@ifvar{zero} aaa',
    };

    varexp($dict, $vars, { pref => '@' });

    is(varval('five.value',$dict), '5', 't_varexp_1 => five');
    is(varval('two.value',$dict), '2', 't_varexp_1  => two');

    is(varval('null',$dict), undef, 't_varexp_1  => null');
    is(varval('null_shift',$dict), undef, 't_varexp_1  => null_shift');

    is(varval('five.plus.three',$dict), '2+2+2+1', 't_varexp_1  => five.plus.three');
    is(varval('five.plus.ten',$dict), '5+10', 't_varexp_1  => five.plus.ten');
    is(varval('twenty.value',$dict), '10+10', 't_varexp_1  => twenty.value');
    is(varval('twenty.two.value',$dict), '10+10+2', 't_varexp_1  => twenty.two.value');
    is(varval('empty',$dict), '', 't_varexp_1  => empty');

    is(varval('null_if_empty',$dict), undef, 't_varexp_1  => null_if_empty');
    is(varval('null_if_empty_shift',$dict), undef, 't_varexp_1  => null_if_empty_shift');
    is(varval('null_if_empty_shift_then',$dict), undef, 't_varexp_1  => null_if_empty_shift_then');

    is(varval('null_if_zero',$dict), undef, 't_varexp_1  => null_if_zero');

    #is(1,1,Dumper($dict));

}

t_vars(0);
t_vars(1);
t_varexp_1();

#is_deeply()

done_testing();
