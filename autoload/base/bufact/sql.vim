

function! base#bufact#sql#file_exec ()
	call base#buf#start()

	let db = 'information_schema'
	let db = input('db:',db)

perl << eof
	use DBI;
	use Vim::Perl qw(:funcs :vars);
	use SQL::SplitStatement;

	my $err = sub{ my @m=@_; for(@m){ VimWarn($_) } };

	my $db   = VimVar('db');
	my $dsn  = "DBI:mysql:database=$db:host=localhost";
	my $user = 'root';
	my $pwd  = '';
	my $attr = {
			RaiseError        => 1,
			PrintError        => 1,
			mysql_enable_utf8 => 1,
	};
	my $dbh = DBI->connect($dsn,$user,$pwd,$attr) || 
		do { $err->($DBI::errstr); return; };

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count ) ];
	my $sql   = join("\n" => @$lines);

  my $spl = SQL::SplitStatement->new; 
	my @sql = $spl->split($sql);

	my $fail=0;

	foreach my $q (@sql) {
		eval { $dbh->do($q,undef,undef) || do { $err->($dbh->errstr,$q); $fail=1;  }; };
		if ($@){ $err->($dbh->errstr,$@); $fail = 1; }
	}

	VimCmd(qq{ let fail = $fail });

eof

	redraw!
	if ( fail == 0 )
		echohl MoreMsg
		echo 'DBI query OK'
		echohl None
	else
		echohl WarningMsg
		echo 'DBI query FAIL'
		echohl None
	endif
	
	
endfunction


