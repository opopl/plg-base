
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

t_vars(0);
t_vars(1);

#is_deeply()

done_testing();
