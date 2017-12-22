
function! base#mysql#query (...)
	if !has('perl')
		return
	endif

	let ref = get(a:000,0,{})
	let q   = get(ref,'q','')
	let db  = get(ref,'db','photos')

	let res = []

perl << eof
	use strict;
	use warnings;

	use DBI;
	use Vim::Perl qw(:funcs :vars);

	my $db = VimEval('db');
	my $q  = VimEval('q');

	my $dbh = DBI->connect("DBI:mysql:database=$db;host=localhost",
                         "root", "",
                         {'RaiseError' => 1});

	my $sth = $dbh->prepare($q);
  $sth->execute();

	my @res;
	while(my @r = $sth->fetchrow_array){
		push @res, join(' ',@r);
	}

	for(@res){
		s/"/\\"/g;
		VimCmd('call add(res,"'.$_.'")');
	}

	$dbh->disconnect;
eof
	return res
	
endfunction
