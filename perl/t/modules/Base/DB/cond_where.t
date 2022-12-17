

use utf8;
use strict;
use warnings;

binmode STDOUT,':encoding(utf8)';

use Test::More;
use Data::Dumper qw(Dumper);
use Algorithm::Permute;

BEGIN {
    require_ok('Base::DB');

    my @funcs = qw(
        cond_where
    );
    use_ok('Base::DB',@funcs);
}

sub t_cond_where {

    my $perms = {
        'abc' => [],
    };
    my @abc = 'a' .. 'c';
    my $p_iterator = Algorithm::Permute->new(\@abc);

    while (my @perm = $p_iterator->next) {
        push @{$perms->{abc}}, [@perm];
    }

    my $q3_and = ' WHERE ( %s = ? ) AND ( %s = ? ) AND ( %s = ? )';
    my $q3_and_perm = [ map { sprintf($q3_and, @$_) } @{$perms->{abc}} ];

    my $data = [
        {
          input => { a => 1, b => 1 },
          expect => {
              q => [
                  ' WHERE ( a = ? ) AND ( b = ? )',
                  ' WHERE ( b = ? ) AND ( a = ? )',
              ],
              p => [ 1, 1 ],
          }
        },
#        {
          #test => 'a_b_c',
          #input => { a => 1, b => 10, c => undef },
          #expect => [
              #q => $q3_and_perm,
              #p => [ 1, 10, undef ],
          #],
        #},
        {
          input => [ { a => 1 } ],
          expect => {
              q => ' WHERE a = ?',
              p => [ 1 ],
          }
        },
        {
          input => [ { a => undef } ],
          expect => {
              q => ' WHERE a = ?',
              p => [ undef ],
          }
        },
        {
          input => [ { a => 1 }, { b => 1 } ],
          expect => {
              q => ' WHERE ( a = ? ) OR ( b = ? )',
              p => [ 1, 1 ],
          }
        },
        {
          input => [ { a => 1 }, { b => 1 }, { c => undef } ],
          expect => {
              q => ' WHERE ( a = ? ) OR ( b = ? ) OR ( c = ? )',
              p => [ 1, 1, undef ],
          }
        },
    ];

    #my $w = [ { a => 1 }, { b => 1 }, { c => undef } ];
    #my ($q, $p) = cond_where($w);

    foreach(@$data) {
        my ($where, $expect, $test) = @{$_}{qw( input expect test )};
        #next unless $test && $test eq 'a_b_c';

        my ($q_got, $p_got) = cond_where($where);

        #ok(1,Dumper($q_got));
        #ok(1,Dumper($p_got));

        my ($q_expect, $p_expect) = @{$expect}{qw( q p )};

        unless (ref $q_expect) {
            is($q_got, $q_expect, 'cond_where query');
        }elsif(ref $q_expect eq 'ARRAY'){
            my $q_any;
            foreach (@$q_expect) {
                $q_any = $_;
                last if $_ eq $q_got;
            }
            is($q_got, $q_any, 'cond_where query');
        }

        is_deeply($p_got, $p_expect, 'cond_where params');
    }

}

t_cond_where();

done_testing();
