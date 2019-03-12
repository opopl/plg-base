
function! base#bufact#sql#split_statements ()
	call base#buf#start()
perl << eof
	use SQL::SplitStatement;
	use Vim::Perl qw(:funcs :vars);

	use File::Basename qw(dirname);
	use File::Spec::Functions qw(catfile);
	use File::Slurp qw( write_file);

	my $file = VimVar('b:file');
	my $dir = dirname($file);

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count ) ];
	my $sql   = join("\n" => @$lines);

  my $spl = SQL::SplitStatement->new; 
	my @sql = $spl->split($sql);

	my $pats = { 
		'create_table' => qr/^CREATE\s+TABLE\s*(?:IF\s+NOT\s+EXISTS|)\s*(\w+)\s*\(/ism,
	};

	foreach my $stm (@sql) {
		my $table;

		{
			local $_ = $stm;
			m/$pats->{create_table}/ && do { $table = $1; };
		}

		next unless $table;

		my $f_sql = catfile($dir,'create_table_' . $table . '.sql' );
		write_file($f_sql,$stm);

		if (-e $f_sql) {
			VimMsg([ 'written file:',"\t".$f_sql ]);
		}

	}

	
eof
endf

function! base#bufact#sql#file_exec ()
	call base#buf#start()

	let dbdriver = input("db driver: ","sqlite","custom,base#complete#dbdrivers")
	let user   = input("user: ","")
	let pwd    = input("pwd: ","")

	call base#varset('dbdriver',dbdriver)

	let defaults = {
		\	'mysql'  : { 'db' :  'information_schema' },
		\	'sqlite' : { 'db' :  '' },
		\	}


	let dbname = input('dbname: ','','custom,base#complete#dbnames')
	let db     = base#dbfile(dbname)

	echo db

	let fail = 1

perl << eof
	use DBI;
	use Vim::Perl qw(:funcs :vars);
	use SQL::SplitStatement;

	my $err = sub{ my @m=@_; for(@m){ VimWarn($_) } };

	my $db       = VimVar('db');
	my $dbdriver = VimVar('dbdriver');
	my $dbds = {
		sqlite => 'SQLite',
	};
	my $dbd = $dbds->{$dbdriver} || $dbdriver;

	my $dsn  = "DBI:$dbd:database=$db:host=localhost";
	my $user = VimVar('user');
	my $pwd  = VimVar('pwd');

	my $attrs = { 
		mysql =>  {
			mysql_enable_utf8 => 1,
		},
		sqlite => { },
	};
	my $attr_default = {
			RaiseError        => 1,
			PrintError        => 1,
	};
	my $attr = $attrs->{$driver} || {};
	for ( keys %$attr_default ){
		$attr->{$_} = $attr_default->{$_}  unless defined $attr->{$_};
	}
 
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

 " redraw!
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


