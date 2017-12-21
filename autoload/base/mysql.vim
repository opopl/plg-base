
function! base#mysql#query (...)
	if !has('perl')
		return
	endif

	let q = get(a:000,0,'')
	let q = 'select * from georgia_2016'
	let db="photos"

perl << eof
	use strict;
	use warnings;

	use DBI;

	my $db = VIM::Eval('db');
	my $q  = VIM::Eval('q');

	my $dbh = DBI->connect("DBI:mysql:database=$db;host=localhost",
                         "root", "",
                         {'RaiseError' => 1});

	my $sth = $dbh->prepare($q);
  $sth->execute();

	while(my @r = $sth->fetchrow_array){
		VIM::Msg(join(' ',@r));
	}
eof
	
endfunction
