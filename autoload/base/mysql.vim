
function! base#mysql#query (...)
	if !has('perl')
		return
	endif

	let q = get(a:000,0,'')
	let db="photos"

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

	while(my @r = $sth->fetchrow_array){
		VIM::Msg(join(' ',@r));
	}

	$dbh->disconnect;
eof
	
endfunction
