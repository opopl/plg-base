
function! base#bufact#csv#add_headers_numeric ()
	call base#buf#start()

	let starthead = input('Start:',0)
	let endhead   = input('End:',10)
	let sep       = input('Separator:',',')
	let prefix    = input('Prefix:','f')

perl << eof
	my $start  = VimVar('starthead');
	my $end    = VimVar('endhead');
	my $sep    = VimVar('sep');
	my $prefix = VimVar('prefix');

	my @h = map { $prefix . $_ } ($start .. $end );
	my $h = join($sep,@h);

	$curbuf->Append(0,$h);
eof
	
endfunction

function! base#bufact#csv#column_count ()
	let start = base#varget('bufact_start',0)
	let end   = base#varget('bufact_end',line('$'))
	let sep   = ","

perl << eof
	my $start = VimVar('start');
	my $end   = VimVar('end');
	my $sep   = VimVar('sep');

	my $l     = $curbuf->Get($start);
	my $count = scalar ( split(/$sep/,$l,-1) );

	VIM::Msg($count);
eof
	
endfunction

function! base#bufact#csv#remove_empty_rows ()
	call base#buf#start()

	let start = base#varget('bufact_start',0)
	let end   = base#varget('bufact_end',line('$'))
	let sep   = ","

endfunction

function! base#bufact#csv#select_to_latex_table ()
	call base#buf#start()

	let start = base#varget('bufact_start',0)
	let end   = base#varget('bufact_end',line('$'))
	let sep   = ","

	let fields   = input('Select fields:','*')
	let textable = []

perl << eof
	use DBI;
	use LaTeX::Table;
	use Vim::Perl qw(:funcs :vars);
	use LaTeX::Encode;
	#use Number::Format qw(:subs);  # use mighty CPAN to format values

	my $start = VimVar('start');
	my $end   = VimVar('end');
	my $sep   = VimVar('sep');

	my $dir   = VimVar('b:dirname');
	my $bname = VimVar('b:basename');

	(my $tb = $bname ) =~ s/\.(\w+)$//g;

	my $warn = sub { VimWarn(@_); };
	my $dbh = DBI->connect("dbi:CSV:", undef, undef, {
		f_schema         => undef,
		f_dir            => "$dir",
		f_dir_search     => [],
		f_ext            => ".csv",
		f_lock           => 2,
		f_encoding       => "utf8",
		csv_eol          => "\n",
		csv_sep_char     => ",",
		csv_quote_char   => '"',
		csv_escape_char  => '"',
		csv_class        => "Text::CSV_XS",
		csv_null         => 0,
		#RaiseError       => 1,
		PrintError       => 1,
	}) or $warn->($DBI::errstr);

	my $fields=VimVar('fields');

	my $sth;
	my $q = qq{ select $fields from $tb };
	my @e = ();

	eval { $sth = $dbh->prepare($q) or $warn->($dbh->errstr); };
	if ($@) { $warn->($q,$@,$dbh->errstr); }

	eval {$sth->execute(@e) or $warn->($dbh->errstr);};
	if ($@) { $warn->($q,$@,$dbh->errstr,Dumper(\@e)); }

	my $header = [];
	my $data   = [];

	my $cb_row = sub { 
		my $cell = shift;
		latex_encode($cell);
	};
	while (my $row = $sth->fetchrow_arrayref) {
		my $r;
		@$r = map { defined($_) ? $cb_row->($_) : '' } @$row;
		push @$data,$r;
	}
	
	my $table = LaTeX::Table->new(
		{   
			filename    => 'prices.tex',
			maincaption => 'Price List',
			caption     => 'Try our special offer today!',
			label       => 'table:prices',
			position    => 'tbp',
			header      => $header,
			data        => $data,
		}
	);

	my $tex = $table->generate_string();
	my @tex = split("\n",$tex);

	VimListExtend('textable',\@tex);
eof
	call base#buf#open_split({ 'lines' : textable })
	
endfunction


