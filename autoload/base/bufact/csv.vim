
function! base#bufact#csv#add_headers_numeric ()

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

	my $l=$curbuf->Get($start);
	my $count = scalar ( split(/$sep/,$l,-1) ); 

	VIM::Msg($count);
eof
	
endfunction

function! base#bufact#csv#remove_empty_rows ()
	let start = base#varget('bufact_start',0)
	let end   = base#varget('bufact_end',line('$'))
	let sep   = ","

endfunction

function! base#bufact#csv#select ()
	let start = base#varget('bufact_start',0)
	let end   = base#varget('bufact_end',line('$'))
	let sep   = ","

	let fields  = input('Select fields:','*')
	let textable = []

perl << eof
	use DBI;
	use LaTeX::Table;
	#use Number::Format qw(:subs);  # use mighty CPAN to format values

	my $start = VimVar('start');
	my $end   = VimVar('end');
	my $sep   = VimVar('sep');

	my $dir   = VimVar('b:dirname');
	my $bname = VimVar('b:basename');

	(my $tb = $bname ) =~ s/\.(\w+)$//g;

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
	}) or die $DBI::errstr;

	my $fields=VimVar('fields');

	my $q=qq{ select $fields from $tb };
	my @e   = ();
	my $sth = $dbh->prepare($q);
	eval {$sth->execute(@e);};

	my $header = [];
	my $data = [];

	while (my $row = $sth->fetchrow_arrayref) {
		my $r;
		@$r = map { defined($_) ? $_ : '' } @$row;
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


