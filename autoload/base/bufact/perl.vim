
function! base#bufact#perl#insert_snip ()
	call base#buf#insert_snip ()
endf

function! base#bufact#perl#pod_to_vimhelp ()
	call base#buf#start()
perl << eof
	use Vim::Perl qw(:funcs :vars);
eof
endf

function! base#bufact#perl#execute ()
	call base#buf#start()

	let vname = 'hist_bufact_perl_execute'
	let hist  = base#varget(vname,[''])
	call base#varset('this',hist)

	let opts = input('perl command-line options: ','','custom,base#complete#this')
	let cmds = []
	let cmd = 'perl ' . b:file . ' ' . opts

	call add(cmds,cmd)

	call add(hist,opts)
	call base#varset(vname,hist)

	let ok = base#sys({ 
		\	"cmds"         : cmds,
		\	"split_output" : 1,
		\	})
	let out    = base#varget('sysout',[])
	let outstr = base#varget('sysoutstr','')

endf

function! base#bufact#perl#pod_process ()
	call base#buf#start()
perl << eof
	use Vim::Perl qw(:funcs :vars);
	$Vim::Perl::CURBUF=$curbuf;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	use Base::Pod;

	my $pp = Base::Pod->new;

	$pp->set_source($lines);
	$pp->run;

eof
endf

function! base#bufact#perl#ppi_vars ()
	call base#buf#start()

	let file = b:file
	let vars = []

	let lines_tags=[]
perl << eof
	use PPI;
	use Data::Dumper;

	use Vim::Perl qw(:funcs :vars);
	use Base::PerlFile;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	$Vim::Perl::CURBUF = $curbuf;

	my $file = VimVar('file');
 	my $DOC = PPI::Document->new($file);
	$DOC->index_locations;

	my $f = sub { $_[1]->isa( 'PPI::Statement::Variable' ) };
	my @v = @{ $DOC->find( $f ) || [] };

	VimMsg(Dumper \@v);
eof
	call base#buf#open_split({ 'lines' : lines_tags })
endf

function! base#bufact#perl#knutov ()
	call base#buf#start()

	let file = b:file
	
	let LINES=[]
perl << eof
	use Base::Tg::Knutov qw(@LINES $FILE);

	$FILE=VimVar('file');
	my @lines=@LINES;
	VimListExtend('LINES',[@lines]);
eof
	call base#buf#open_split({ 'lines' : LINES })

endfunction

function! base#bufact#perl#pod_to_text ()
	call base#buf#start()

endfunction

function! base#bufact#perl#extract_subs ()
	call base#buf#start()

	let file = b:file
	let lines = []
perl << eof
	use Base::Tg::ExtractSubs qw($FILE @LINES);
	$FILE=VimVar('file');

	Base::Tg::ExtractSubs::main();

	VimListExtend('lines',[@LINES]);
eof
	call base#buf#open_split({ 'lines' : lines })
	
endfunction

"""ppi_load
function! base#bufact#perl#ppi_process ()
	call base#buf#start()

	let file = b:file

	let lines = []
perl << eof
	use Vim::Perl qw(VimVar);
	use Base::PerlFile;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	$Vim::Perl::CURBUF = $curbuf;

	my $file = VimVar('file');
	my %o = (
		sub_log  => sub { VimMsg(@_); },
		sub_warn => sub { VimWarn(@_); },
		dbfile	 => ':memory:',
	);

	our $PF = Base::PerlFile->new(%o);
	$PF
		->ppi_process({ file => $file });
eof

endfunction


"""ppi_list_subs
function! base#bufact#perl#ppi_list_subs ()
	call base#buf#start()

	let file = b:file

	let lines = []
perl << eof
	use PPI;
	use Data::Dumper;

	use Vim::Perl qw(:funcs :vars);
	use Base::PerlFile;
	use YAML qw(Dump Bless);

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	$Vim::Perl::CURBUF = $curbuf;

	my $file = VimVar('file');
	my %o = ();

	my $pf = Base::PerlFile->new(%o);
	$pf
		->ppi_process({ file => $file })
		;

#	VimListExtend('lines_tags',$pf->{lines_tags});
	my $subnames   = $pf->subnames;
	my $namespaces = $pf->namespaces;

	eval { Bless($subnames)->keys($namespaces); };
	my @sb_yaml = split("\n",Dump($subnames));

	my $skip = { map { $_ => 1 } qw(undefined spaces) };
	my $opts = {
		skip => $skip,
	};
	@sb_yaml = map { s/^(\s*)\-/$1/g; $_ } @sb_yaml;
	VimListExtend('lines',[@sb_yaml],$opts);
eof
	call base#buf#open_split({ 'lines' : lines })
endf

"htmllines	/home/mmedevel/repos/git/htmltool/lib/HTML/Work.pm	/^sub htmllines {$/;"	s
