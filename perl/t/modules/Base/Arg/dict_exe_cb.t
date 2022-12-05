
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
    );
    use_ok('Base::Arg',@funcs);
}

sub t_vars {
    my $a_z = [( 'a' .. 'z' )];

    my $expected = {
        z0 => {
            a => {
              'a' => $a_z,
              'b' => [],
              'c' => [
                       'section',
                       'section'
                     ]
            }
        }
    };

    my $vars = {
        sec => 'section',
        zero => 0,
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

    my $a0 = dict_exe_cb(clone($a), {
        cb => sub { },
        cb_list => sub { varexp(shift, $vars); },
    });
    is_deeply($a0, $expected->{z0}->{a},'dict_exe_cb + list varexp');
}

t_vars();

#is_deeply()

done_testing();
