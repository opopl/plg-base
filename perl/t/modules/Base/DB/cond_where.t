

use utf8;
use strict;
use warnings;

binmode STDOUT,':encoding(utf8)';

use Test::More;                     
use Data::Dumper qw(Dumper);

BEGIN {
    require_ok('Base::DB');

    my @funcs = qw(
        cond_where
    );
    use_ok('Base::DB',@funcs);
}

sub t_cond_where {
	my $data = [
		{ 
		  input => { a => 1, b => 1 },
		  expect => { 
			  q => ' WHERE a = ?  AND b = ? ',
			  p => [ 1, 1 ],
		  }
		},
		#{ 
		  #input => { a => 1, b => 1, c => undef },
		  #expect => { 
			  #q => ' WHERE a = ?  AND b = ?  AND c = ? ',
			  #p => [ 1, 1, undef ],
		  #}
		#},
	];

	my $w = { a => 1, b => 1 };
	my ($q, $p) = cond_where($w);


	foreach(@$data) {
		my $where = $_->{input},
		my $expect = $_->{expect};

		my ($q_got, $p_got) = cond_where($where);

		#ok(1, Dumper($q_got));

		is($q_got, $expect->{q}, 'cond_where query');
		is_deeply($p_got, $expect->{p}, 'cond_where params');

	}

	#ok(1, Dumper($q));
	#ok(1, Dumper($p));

    #is($ax, $expected->{zero}->{$zero}->{a},'dict_exe_cb: cb_list => varexp, zero => ' . $zero);
}

t_cond_where();

done_testing();
