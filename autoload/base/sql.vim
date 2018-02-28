function! base#sql#q (q,...)
	let q=a:q

	let ref = get(a:000,0,{})

	let fmt    = get(ref,'pack_fmt','a10')
	let dbtype = get(ref,'db_type','sqlite')
	let opp    = get(ref,'opt_print','perlpack')
	let fetch  = get(ref,'fetch','fetchrow_arrayref')

	let lines=[]
perl << eof
	use Vim::Perl qw(:funcs :vars);

	my $dbh;

	my $dbtype = VimVar('dbtype');
	for($dbtype){
			/^sqlite$/&& do {
				$dbh=$plgbase->dbh;
				next;
			};
			/^mysql$/&& do {
				$dbh=$vimdbi->dbh;
				next;
			};
			last;
	}

	defined $dbh or do { VimWarn('base#sql#q: $dbh undefined!!'); return; };

	my $q     = VimVar('q');
	my $fmt   = VimVar('fmt');
	my $opp   = VimVar('opp');
	my $fetch = VimVar('fetch');

	my $sth;
	eval {$sth = $dbh->prepare($q); };
	my $errstr = $dbh->errstr;
	if ($@) {
		my $s = 'eval {$sth = $dbh->prepare($q);};';
		my @m ='base#sql#q: errors for: ',$s,$@,$errstr;
		VimWarn(@m);
		return;
	}
	defined $sth or do { 
		my @m;
		push @m,'base#sql#q: $sth undefined!!',$errstr;
		VimWarn(@m); 
		return; 
	};
	
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
