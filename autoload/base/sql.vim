function! base#sql#q_sqlite (q,...)
	let q=a:q

	let ref = get(a:000,0,{})

	let fmt   = get(ref,'pack_fmt','a10')
	let opp   = get(ref,'opt_print','perlpack')
	let fetch = get(ref,'fetch','fetchrow_arrayref')

	let lines=[]
perl << eof
	my $dbh=$plgbase->dbh;

	my $q   = VimVar('q');
	my $fmt = VimVar('fmt');
	my $opp = VimVar('opp');
	my $fetch = VimVar('fetch');

	my $sth = $dbh->prepare($q);
	$sth->execute;

	my $lines;
	my $fetchrow = sub { $sth->fetchrow_arrayref };

	while (my $row=$fetchrow->()) {
		my $line;

		for($opp){
			/perlpack/ && do {
				$line = pack($fmt,( map { (defined $_) ? $_ : '' } @$row ));
				next;
			};
			/perldumper/ && do {
				$line = Dumper($row);
				next;
			};
			last;
		}

		push @$lines,split("\n",$line);
	}
	VimListExtend('lines',$lines);
	
eof
	return lines
	
endfunction
