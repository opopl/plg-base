
"echo base#html#tag('th')
"echo base#html#tag('th','Row')
"echo base#html#tag('th','Row',{2:2})

function! base#html#tag (...)
	let tag = get(a:000,0,'')
	let txt = get(a:000,1,'')
	let attr = get(a:000,2,{})

	let op = '<'.tag

	for [k,v] in items(attr)
			let op = op . ' '. '"'.k.'"='.'"'.v.'"'
	endfor
	let op = op . '>'

	let cl = '</'.tag.'>'
	let s = op.txt.cl

	return s
	
endfunction

function! base#html#strip(string)
	if !has('perl')
		return
	endif

perl << eof
	use utf8;

	use Vim::Perl qw(:funcs :vars);
	use CSS;

	use HTML::Strip;

	my $hs = HTML::Strip->new();

  my $clean_text = $hs->parse( $raw_html );
  $hs->eof;

eof

endfunction

function! base#html#file_info (...)
	let ref   = get(a:000,0,{})

	let inf = {}

	let file  = get(ref,'file','')

	if filereadable(file)
		 let lines = readfile(file)
	endif
	let html = join(lines,"\n")

	let h = base#html#headings({ 'file' : file })

	let f =  base#html#xpath({ 
		\	'file'       : file,
		\	'xpath'      : '//title/text()',
		\	'trim'       : 1,
		\	'skip_empty' : 1,
		\	})
	let title = join(f,'')


	let attr = {}

	let a =  base#html#xpath_attr({ 
		\	'file'       : file,
		\	'xpath'      : '//base',
		\	'attr'       : base#qw('href'),
		\	})
	let base = get(a,0,'')

	call extend(inf,{ 'title' :  title, 'base' : base })

	if exists("b:html_info")
		unlet b:html_info
		let b:html_info = inf
	endif

	return inf

endfunction


function! base#html#headings (...)
	let ref   = get(a:000,0,{})

	let lines = get(ref,'lines',[])
	let file  = get(ref,'file','')

	if filereadable(file)
		 let lines=readfile(file)
	endif
	let html = join(lines,"\n")

	let headnums = base#listnewinc(1,5,1)
	let heads    = map(headnums,'"self::h".string(v:val)')
	let he       = join(heads,' or ')
	let h        = []

	let xpath = '//*['.he.']'

perl << eof
	use Base::Xml qw($PARSER $PARSER_OPTS);

	use XML::LibXML;
	use XML::LibXML::PrettyPrint;
	use Encode qw(decode);
	my ($dom,@nodes,$parser);

	$parser=$PARSER || XML::LibXML->new; 

	#	my $xpath    = VimVar('xpath');
	my $html = VimVar('html');

	my @headnums = (1 .. 5);
	my @heads    = map { "self::h" . $_ } @headnums;
	my $he       = join(' or ',@heads);
	my $xpath    = '//*['.$he.']';

#"//*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5]
#//*[preceding-sibling::h2 = 'Summary' and following-sibling::h2 = 'Location']

	my $xml_libxml_parser_options = $PARSER_OPTS || 
	{
			expand_entities => 0,
			load_ext_dtd 		=> 1,
			keep_blanks     => 1,
			no_cdata        => 0,
			line_numbers    => 1,
	};

	$parser->set_options(%$xml_libxml_parser_options);

	my $inp={
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	};

	$dom = $parser->load_html(%$inp);

	my $nodelist = $dom->findnodes($xpath);
	my $sub      = sub { local $_ = shift; s/^h(\d+)/$1/g; $_ };
	my @children;
	my @sn;

	my $pp     = XML::LibXML::PrettyPrint->new(indent_string => " ");
	#my $newdom = XML::LibXML::Document->new;

	my %added=();
	my @nodes;
	while(my $node = $nodelist->pop) {
		 unshift @nodes,$node;
		 my $lnum=$node->line_number;
 		 $pp->pretty_print($node);

		 my $pos = $nodelist->size;
		 my $cmt = "*" x 10 . "pos: ".$pos;
		 my $cn  = XML::LibXML::Comment->new($cmt);

		 $node->setAttribute('node_lineno',$lnum);
		 $node->setAttribute('node_id',$pos);

		 my $text=$node->textContent;
		 $text=~s/^\s*//g;
		 $text=~s/\s*$//g;
		 $node->setAttribute('node_text',$text);
		 my @textchildren;
		 
		 for($node->childNodes() ){
				if ($_->nodeType == XML_TEXT_NODE) {
					push @textchildren,$_;
				}
		 }
		 for my $tchild (@textchildren){
		 		$node->removeChild($tchild);
		 }

		 my $prev = $nodelist->get_node($pos);
		 last unless $prev;

		 my $n_prev = $sub->($prev->nodeName);
		 my $n_node = $sub->($node->nodeName);
		 my %n=(
			 	prev => $n_prev,
			 	node => $n_node,
		 );

		 unshift @children,{ 
		 		node => $node,
				num  => $n_node,
				line => $node->line_number,
		 };
		 
		 if ($n{prev} < $n{node}) {
				for my $c (@children){
					my $child      = $c->{node};
					my $child_num  = $c->{num};
					my $child_line = $c->{line};

					my $clone=$child->cloneNode(1);

					next if ($n{prev} > $child_num);

					$prev->addChild($child);
					$added{$child_line}=1;
				}
				@children=();
		 }else{
		 }
	}

	my @n = map { $added{$_->line_number} ? $_ : () } @nodes;
	my @s = map { $pp->pretty_print($_); $_->toString } @n;

	my $stars = '*' x 50;
	VimMsg([$stars,'Added nodes',$stars]);
	for(@s){
		VimMsg('-'x 50);
		VimMsg($_);
	}
	
eof

	return h
	
endfunction

function! base#html#text_between_headings (...)
	let ref   = get(a:000,0,{})
	let lines = get(ref,'lines',[])

	let text = []
	let h    = base#html#headings(ref)

	return text

endfunction

function! base#html#css_pretty(string)
	if !has('perl')
		return
	endif
	let css_pp=[]

perl << eof
	use utf8;

	use Vim::Perl qw(:funcs :vars);
	use CSS;

	my $str=VimVar('a:string');
	my $css=CSS->new({ 'adaptor' => 'CSS::Adaptor::Pretty' });

	$css->read_string($str);

	my $o = $css->output();
	my @o = split("\n",$o);

	VimListExtend('css_pp',[@o]);

eof
	return css_pp

endfunction

function! base#html#remove_a(...)
	if !has('perl') | return | endif

	let ref       = get(a:000,0,{})

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])

	if len(htmllines)
		let htmltext=join(htmllines,"\n")
	endif

	let lines = []

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	my $html  = VimVar('htmltext');
	
	our $HTW = HTML::Work->new(
		html => $html,
	);
	$HTW->replace_a;
	my $lines = $HTW->htmllines;

	VimListExtend('lines',$lines);

eof
	return lines

endfunction

function! base#html#remove_a_libxml(...)
	if !has('perl') | return | endif

	let ref       = get(a:000,0,{})

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])

	if len(htmllines)
		let htmltext=join(htmllines,"\n")
	endif

	let lines = []

perl << eof

	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	my $html  = VimVar('htmltext');

	our $HTW ||= HTML::Work->new(
		html    => $html,
		sub_log => sub { VimMsg($_) for(@_); },
	);
	$HTW->replace_a;

	my @lines   = $HTW->htmllines;

	VimListExtend(lines,\@lines);

eof
	return lines

endfunction

function! base#html#htw_init (...)
	let ref = get(a:000,0,{})

	let dbfile = ':memory:'
	let dbfile = base#htw_dbfile() 
	let dbfile = get(ref,'dbfile',dbfile)

	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	let msg = ['start']
	let prf = {'plugin' : 'base', 'func' : 'base#html#htw_init'}
	call base#log(msg,prf)
	let l:start=localtime()
	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

perl << eof
	use HTML::Work;

	my $dbfile = VimVar('dbfile');

	my $prf = { dbfile => $dbfile };
	our $HTW ||= HTML::Work->new(
			def_PRINT => sub { VimMsg([@_],$prf) },
			def_WARN  => sub { VimWarn([@_],$prf) },
			dbfile    => $dbfile,
			load_as   => 'html',
	);
eof
endfunction

"used in : idephp_cmd_fetch_url_source

function! base#html#fetch_url_source (...)
	call base#html#htw_init ()

	let ref = get(a:000,0,{})
	let url = get(ref,'url','')

	let save_dir = base#qw#catpath('saved_urls','')
	let save_dir = get(ref,'save_dir',save_dir)

	let tags  = get(ref,'tags','')
	let title = get(ref,'title','')

	let save_db = base#qw#catpath('db','saved_urls.sqlite')
	let save_db = get(ref,'save_db',save_db)

	let saved_bname = get(ref,'saved_bname','')
	
perl << eof
	use Vim::Perl qw(VimVar VimMsg CurBufSet);

	use File::Spec::Functions qw(catfile);
	use File::Copy qw(move);
	use File::Path qw(mkpath);

	use LWP;
	use HTTP::Request;

	use DBI;
	use Base::DB qw(
		dbh_insert_hash 
		dbh_do
		dbh_select
		dbh_select_fetchone
		dbh_list_tables
	);

	my $save_db  = VimVar('save_db');

	$Vim::Perl::DBH = undef;

	my $dsn      = "dbi:SQLite:dbname=$save_db";
	
	my $user     = "";
	my $password = "";
	my $dbh = DBI->connect($dsn, $user, $password, {
		PrintError       => 1,
		RaiseError       => 1,
		AutoCommit       => 1,
		FetchHashKeyName => 'NAME_lc',
	});

	my $warn = sub { VimWarn([$_]) for(@_) };
	$Base::DB::DBH  = $dbh;
	$Base::DB::WARN = $warn;

	my $q = qq{
		CREATE TABLE IF NOT EXISTS pages  (
			url TEXT NOT NULL UNIQUE,
			url_host TEXT,
			url_query TEXT,
			time_saved INTEGER,
			txt_file TEXT,
			saved_file TEXT UNIQUE,
			saved_bname TEXT,
			pcname TEXT,
			tags TEXT,
			title TEXT,
			source_html TEXT,
			converted_text TEXT
		);
	};
	#ALTER TABLE pages ADD COLUMN pcname TEXT;
	#ALTER TABLE pages ADD COLUMN txt_file TEXT;
	#ALTER TABLE pages ADD COLUMN time_saved INTEGER;
	dbh_do({ q => $q }) or do { return; };
 
	my $ref      = VimVar('ref');

	my $url   = VimVar('url');
	my $tags  = VimVar('tags');
	my $title = VimVar('title');

	my $table = 'pages';
	my $f = [ qw( 
		rowid 
		url url_host url_query
		saved_file saved_bname 
		txt_file
		tags title 
	) ];

	my $sav = dbh_select({
		t    => $table,
		f    => $f,
		p    => [ $url ],
		cond => q{ WHERE url = ? },
	});

	my $set_db_info = sub {
		my ($r,$table,$dbfile)=@_;

		my $db_info = {
			record  => $r,
			table   => $table,
			dbfile  => $dbfile,
		};
		VimLet('b:db_info',$db_info);
	};

	if (@$sav) {
		unless ($ref->{rewrite}) {
			foreach my $r (@$sav) {
				my $cached_file = $r->{saved_file};
				my $rowid       = $r->{rowid};

				if (-e $cached_file) {
					VimFileOpen({ file => $cached_file });
					$set_db_info->($r,$table,$save_db);
				}else{		
					VimWarn('No file:',"\t". $cached_file);
				}
			}
			return;
		}
	}

	my $save_dir = VimVar('save_dir');
	mkpath $save_dir unless -d $save_dir;

	my $saved_bname = VimVar('saved_bname');

	my ($saved_file,$txt_file);
	{
		local $_ = $saved_bname;

		s/$/\.htm/g unless /\.(html|htm)$/;
		s/\.php$/\.htm/g;

		$saved_file = catfile($save_dir,$_);
		$txt_file   = catfile($save_dir,$saved_bname . '.txt');
	};

	$HTW->download_url({
		remote  => $url,
		local   => $saved_file,
		rewrite => 1,
	});

	my $pcname = ($^O eq 'Win32') ?  $ENV{COMPUTERNAME} : $ENV{HOSTNAME};
	my $h = { 
		url         => $url,
		saved_bname => $saved_bname,
		saved_file  => $saved_file,
		tags        => $tags,
		title       => $title,
		pcname      => $pcname,
		time_saved  => time(),
		url_host    => '',
		url_query   => '',
	};

	dbh_insert_hash({ 
		t    => 'pages',
		h    => $h,
		i    => qq{INSERT OR REPLACE},
	});
	$h->{rowid} = dbh_select_fetchone({  
		q => 'SELECT last_insert_rowid() FROM pages',
	});

	if (-e $saved_file) {
		VimFileOpen({ file => $saved_file });
		$set_db_info->($h,'pages',$save_db);
	}

	$dbh->disconnect;
	if ($@) { VimWarn($@); }
eof

endfunction

function! base#html#download_site (...)
	call base#html#htw_init()

	let ref      = get(a:000,0,{})

	" required
	let save_dir = get(ref,'save_dir','')
	let root     = get(ref,'root','')
	let bname    = get(ref,'bname','')

	let site     = get(ref,'site','')

	" optional
	let proto    = get(ref,'proto','http')

perl << eof
	my $save_dir = VimVar('save_dir');
	my $root     = VimVar('root');
	my $bname    = VimVar('bname');
	my $proto    = VimVar('proto');

	$HTW->download_site({
			savedir     => $save_dir,
			root        => $root,
			bname       => 'index',
			bnames_find => 1,
			proto       => $proto,
	});
eof

endfunction

function! base#html#save_db(...)
		let save_db = base#qw#catpath('db','saved_urls.sqlite')
		return save_db
endfunction

function! base#html#url_is_cached (...)
	let url = get(a:000,0,'')
	let ref = get(a:000,1,{})

	let save_db = base#html#save_db()
	let save_db = get(ref,'save_db',save_db)

	let table   = get(ref,'table','pages')

	let q = 'SELECT saved_file FROM ' . table . ' WHERE url = ?'
	let p = [ url ]
	
	let list = pymy#sqlite#query_as_list({
		\	'dbfile' : save_db,
		\	'p'      : p,
		\	'q'      : q,
		\	})
	let saved_file = get(list,0,'')
	if filereadable(saved_file)
		return 1
	endif

	return 0

endfunction


function! base#html#url_load (...)
	let ref=get(a:000,0,{})

	call base#html#htw_init ()
	call perlmy#dbi#connect()

	let load_as      = base#html#libxml_load_as()
perl << eof
	use Vim::Perl qw(:vars :funcs);
	use Base::Util;

	use SQL::SplitStatement;
	use String::Escape qw(escape);

	use File::Path qw(mkpath);
	use File::Basename qw(basename);
	use File::Slurp qw(write_file);
	use File::Spec::Functions qw(catfile);

	my $saved_urls = catfile($ENV{appdata},qw(vim plg base saved_urls ));
	mkpath $saved_urls unless -d $saved_urls;

	my $ref = VimVar('ref') || {};
	my $url = $ref->{url} || '';

	my $req;
	my $http_headers = {
		  'User-Agent'      => 'Mozilla/4.76 [en] (Win98; U)',
		  'Accept'          => 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*',
		  'Accept-Charset'  => 'iso-8859-1,*,utf-8',
		  'Accept-Language' => 'en-US',
	};
	$HTW->load_html_from_url({
			url          => $url,
			req          => $req,
			http_headers => $http_headers,
	});
	VimMsg($HTW->{status_line});
	my $html  = $HTW->htmlstr;
	my $stats = $HTW->{html_stats};

	my $baseutil = Base::Util->new;

	my ($file_local_text,$file_local_html);
	my ($contents_text);

	{ # save to local text file
		my $cmd = qq{ let save2txt = input("Save to local text file? 1/0:",1) };
		VimCmd($cmd);
		my $save2txt = VimVar('save2txt');

		my $vh_tag          = '';

		if ($save2txt) {
				my $max = $baseutil->get_max_num({ 
					dir  => $saved_urls,
					exts => [qw(html)],
			 	});
				$max++;

				{
					my $cmd = qq{ let vh_tag = input("VimHelp tag:","$vh_tag") };
					VimCmd($cmd);
					$vh_tag = VimVar('vh_tag');
				}

				$file_local_html = catfile($saved_urls,$max . '.html');
				$file_local_text = catfile($saved_urls,$max . '.txt');

				{
					my ($f_html,$f_text)=map { escape('printable',$_)} ($file_local_html,$file_local_text);
					my $cmd = qq{ 
						let file_local_html = input("Local html file:","$f_html") 
						let file_local_text = input("Local text file:","$f_text") 
					};
					VimCmd($cmd);
					$file_local_html = VimVar('file_local_html');
					$file_local_text = VimVar('file_local_text');
				}

				my $vhref={
					out_vh_file => $file_local_text,
					tag         => $vh_tag,
					actions     => [qw( replace_a replace_pre )],
					xpath_rm    => [],
					xpath_cb    => [],
				};
			
				my $lines      = $HTW->save_to_vh($vhref);
				$contents_text = join("\n",@$lines);

				if (-e $file_local_text) {
					VimMsg('URL has been written locally (TEXT)');
				}

				write_file($file_local_html,$html);

				if (-e $file_local_html) {
					VimMsg('URL has been written locally (HTML)');
				}
		}
	}

	{ # save to DB
		my $cmd = qq { let save2db = input("Save to DB? 1/0:",1) };
		VimCmd($cmd);
		my $save2db = VimVar('save2db');

		my $title = $stats->{title} || '';
		my $cmd   = qq{ let title = input("Title:","$title") };
		VimCmd($cmd);
		$title = VimVar('title');

		if ($save2db) {
			my $cmd;

			my $dbh = $vimdbi->dbh;
			my $db;
			{
				my $cmd = qq{ let db=input('DB name:','docs_sphinx') };
				$db     = VimVar('db');
			}
			$dbh->do("use $db");

			$cmd   = qq{ let doc_id = input("doc_id:","") };
			VimCmd($cmd);
			my $doc_id = VimVar('doc_id');
			my $local_id;

			$cmd   = qq{ let doc_tags= input("doc_tags:","") };
			VimCmd($cmd);
			my $doc_tags = VimVar('doc_tags');

			{
				local $_ = basename($file_local_text); 
				s/\.txt$//g;
				$local_id = $_;
			}
			
			my $comma=",";
			my @ins=qw(
				title url_remote 
				doc_id local_id tags
				file_local_text file_local_html
				contents_text contents_html
			);
			my $ins   = join($comma,@ins);
			my $qvals = join($comma, map { "?" } ( 1 .. scalar @ins ) );

			my $q = qq{
				insert into documents ( time_added, $ins ) values ( now(), $qvals)
			};
			my %bind = (
				title           => $title,
				url_remote      => $url,
				file_local_text => $file_local_text,
				file_local_html => $file_local_html,
				doc_id          => $doc_id,
				tags            => $doc_tags,
				local_id        => $local_id,
				contents_html   => $html,
				contents_text   => $contents_text,
			);
			my @bind = @bind{@ins};

			my $spl      = SQL::SplitStatement->new;
			my @splitted = $spl->split($q);
			foreach my $q (@splitted) {
				$dbh->do($q,undef,@bind) or 
					VimWarn($q,join(' ',@bind));
			}
			$dbh->commit;
		}
	}

	{ # split view of the saved html
		my $cmd = qq {
			let spl = input("Split contents? 1/0:",1)
			if spl | enew | split | endif
		};
		VimCmd($cmd);
		my $spl = VimVar('spl');
	
		if ($spl) {
			CurBufSet({ 
				curbuf => $curbuf,
				text   => $html,
			});
		}
	}
eof
endfunction

function! base#html#xpath_attr (...)
	call base#html#htw_init ()

	let ref = get(a:000,0,{})

	let xpath     = get(ref,'xpath','')
	let attr_list = get(ref,'attr',[])

	let attr_values=[]

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])

	let file      = get(ref,'file','')

	if filereadable(file)
		let htmllines = readfile(file)
	endif

	if len(htmllines)
		 let htmltext = join(htmllines,"\n")
	endif

	let load_as      = base#html#libxml_load_as()
	let load_as      = get(ref,'load_as',load_as)

perl << eof
		use Vim::Perl qw(:funcs :vars);
		use XML::LibXML;

		my $ref          = VimVar('ref') || {};

		my $html         = VimVar('htmltext');
		my $load_as      = VimVar('load_as');

		my $xpath     = VimVar('xpath') || '';

		my $attr_list = VimVar('attr_list') || [];
		my $attr_values  = [];

		my @nodes = $HTW
			->init_dom({ 
					html    => $html,
			,		load_as => $load_as,
			})
			->nodes({ xpath => $xpath });

		foreach my $attr_name (@$attr_list) {
			foreach my $n (@nodes) {
				my $attr = $n->getAttribute($attr_name);

				my $val = ((defined $attr) ? $attr : '');

				push @$attr_values, $val;
			}
		}
		VimListExtend('attr_values',$attr_values);
eof
		return attr_values

endfunction

function! base#html#list_href ()
	call base#html#htw_init ()
	let href = []
perl << eof
	my @href = $HTW->list_attr({ 
		xpath       => '//a',
		node_filter => sub{ 1 },
		attr        => 'href',
	});
	VimLet('href',[@href]);
eof
	return href

endfunction

function! base#html#htw_load_buf ()
	call base#html#htw_init ()

	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	let msg = ['start']
	let prf = {'plugin' : 'base', 'func' : 'base#html#htw_load_buf'}
	call base#log(msg,prf)
	let l:start = localtime()
	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	let load_as      = base#html#libxml_load_as()
perl << eof
	use Vim::Perl qw(:funcs :vars);
	$Vim::Perl::CURBUF = $curbuf;

	my $load_as = VimVar('load_as');
	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];
	$HTW
		->init_dom({ 
				htmllines => $lines,
				load_as   => $load_as,
		})
		;
	our $DOM = $HTW->{dom};
eof
	
endfunction

function! base#html#xpath(...)
	if !has('perl') | return | endif

	call base#html#htw_init()

	let ref      = get(a:000,0,{})

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])
	let xpath     = get(ref,'xpath','')

	let file      = get(ref,'file','')

	let add_comments = get(ref,'add_comments',0)
	let cdata2text   = get(ref,'cdata2text',0)

	let load_as      = base#html#libxml_load_as()
	let load_as      = get(ref,'load_as',load_as)

	if filereadable(file)
		let htmllines = readfile(file)
	endif

	if len(htmllines)
		 let htmltext = join(htmllines,"\n")
	endif

	let filtered=[]

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use XML::LibXML;
	use HTML::Entities;
	use String::Util qw(trim);

	my $html         = VimVar('htmltext');
	my $xpath        = VimVar('xpath');
	my $ref          = VimVar('ref') || {};

	my $add_comments = VimVar('add_comments');
	my $cdata2text   = VimVar('cdata2text');
	my $load_as      = VimVar('load_as');

	my @nodes = $HTW
		->init_dom({ 
				html    => $html,
		,		load_as => $load_as,
		})
		->nodes({ xpath => $xpath });

	my @filtered;

	for my $node (@nodes){
		my $ntype=$node->nodeType;
		if ($add_comments) {
			my $cmts = [
				'nodeType='.$nodetypes{$ntype} || 'undef',
			];
			foreach my $cmt (@$cmts) {
				my $cnode = XML::LibXML::Comment->new($cmt);
				push @filtered, $cnode->toString;
			}
		}

		if ($cdata2text) {
			$node = $HTW->node_cdata2text({ 
				node   => $node,
				dom    => $dom,
				parser => $parser });
		}
		push @filtered,split("\n",$node->toString);
	}
	@filtered = map { decode_entities($_) } @filtered;

	if ($ref->{trim}) {
		map { $_ = trim($_) } @filtered;
	}
	if ($ref->{skip_empty}) {
		@filtered = map { /^\s*$/ ? () : $_ } @filtered;
	}

	VimListExtend('filtered',\@filtered);
eof

	return filtered

endfunction

function! base#html#xpath_lineno(...)
	if !has('perl') | return | endif

	let ref      = get(a:000,0,{})

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])
	let xpath     = get(ref,'xpath','')

	if len(htmllines)
		 let htmltext=join(htmllines,"\n")
	endif

	let filtered=split(htmltext,"\n")
	let filtered=[]
	if !strlen(xpath)
		echohl WarningMsg
		echo 'Empty XPATH'
		echohl None
		return filtered
	endif

perl << eof
	# read https://habrahabr.ru/post/53578/ about encodings
	# http://www.nestor.minsk.by/sr/2008/09/sr80902.html
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use XML::LibXML;
	use XML::LibXML::PrettyPrint;

	my $html  = VimVar('htmltext');
	my $xpath = VimVar('xpath');

	my ($dom,@nodes,@filtered);

	$dom = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);

	@nodes=$dom->findnodes($xpath);

	for my $node (@nodes){
		VimLet('string',$node->toString);
		VimLet('lnum',$node->line_number);
		VimLet('text',$node->textContent || '');
		my $cmd = 'call add(filtered,' ;
		$cmd .='{ "lnum"   : lnum, '   ;
		$cmd .='  "text"   : text,'    ;
		$cmd .='  "string" : string,'  ;
		$cmd .='})'                    ;
		VimCmd($cmd);
	}

eof

	return filtered

endfunction

function! base#html#xpath_remove_nodes(...)
	if !has('perl') | return | endif

	call base#html#htw_init()

	let ref      = get(a:000,0,{})

	let opts    = base#varget('opts',{})
	let load_as = get(opts,'libxml_load_as','')
	let load_as = get(ref,'load_as',load_as)

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])
	let xpath     = get(ref,'xpath','')

	if len(htmllines)
		 let htmltext=join(htmllines,"\n")
	endif

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	my $ref     = VimVar('ref') || {};

	my $html    = VimVar('htmltext');
	my $xpath   = VimVar('xpath');
	my $load_as = VimVar('load_as');

	$html = $HTW
		->init_dom({ 
			html    => $html,
			load_as => $load_as,
		})
		->nodes_remove({ xpath => $xpath })
		->htmlstr;

	if ($ref->{fillbuf}) {
		CurBufSet({ text => $html, curbuf => $curbuf });
	}
	VimLet('htmltext',html);
	return $html;
eof

endfunction

function! base#html#xpath_remove_attr(...)
	if !has('perl') | return | endif

	let ref      = get(a:000,0,{})

	let opts    = base#varget('opts',{})
	let load_as = get(opts,'libxml_load_as','')
	let load_as = get(ref,'load_as',load_as)

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])
	let xpath     = get(ref,'xpath','')

	if len(htmllines)
		 let htmltext=join(htmllines,"\n")
	endif

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	my $ref     = VimVar('ref') || {};

	my $html    = VimVar('htmltext');
	my $xpath   = VimVar('xpath');
	my $load_as = VimVar('load_as');

	our $HTW ||= HTML::Work->new(sub_log => sub { VimWarn(@_); });

	$html = $HTW
		->init_dom({ 
			html    => $html,
			load_as => $load_as,
		})
		->nodes_remove_attr({ xpath => $xpath })
		->htmlstr;

	if ($ref->{fillbuf}) {
		CurBufSet({ text => $html });
	}
	VimLet('htmltext',html);
	return $html;
eof

endfunction


function! base#html#list_to_txt(html)
	if !has('perl')
		return
	endif
	let lines=[]

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use XML::LibXML;

	my $html=VimVar('a:html');

	my $doc = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);
	my $xpath='//[ul|ol]/li'

	my @nodes=$dom->findnodes($xpath);
eof
 " my @filtered;

	"for(@nodes){
		"push @filtered,split("\n",$_->toString);
	"}

	"VimListExtend('filtered',\@filtered);

endfunction


function! base#html#libxml_load_as()
	let opts    = base#varget('opts',{})
	let load_as = get(opts,'libxml_load_as','')
	return load_as
endfunction

function! base#html#pretty_libxml(...)
	
	if !has('perl') | return [] | endif

	let ref      = get(a:000,0,{})
	let htmltext = get(ref,'htmltext','')

	let load_as      = base#html#libxml_load_as()
	let load_as      = get(ref,'load_as',load_as)

	let html_pp=[]

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	our $HTW  ||= HTML::Work->new( sub_log => sub { VimWarn(@_); } );

	my $ref     = VimVar('ref');
	my $load_as = VimVar('load_as');

	my $html = VimVar('htmltext');

	my $html_pp = $HTW
		->init_dom({ 
			html    => $html,
			load_as => $load_as,
		})
		->dom_pretty
		->htmlstr;

	if ($ref->{fillbuf}) {
		my $c=$curbuf->Count(); 
		$curbuf->Delete(1,$c);
		$curbuf->Append(1,split("\n",$html_pp));
	}

	push @pp,(split("\n",$html_pp));
	VimListExtend('html_pp',\@pp);
eof

	return html_pp

endfunction
