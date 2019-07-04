"""BufAct_lynx_dump_split
function! base#bufact#html#dump_split ()
	call base#buf#start()

	let lines = getline(0,'$') 
	let tmp   = tempname()
	call writefile(lines,tmp)

	let exe_dump = ''
perl << eof
	use Base::Const qw(EXE_DUMP_HTML);
	my $exe = EXE_DUMP_HTML;

	VimLet('exe_dump',"$exe");
eof

	let cmd = exe_dump . ' ' . tmp
	let cmd = input('Conversion cmd: ',cmd)

	echo tmp
	call base#sys({ 
		\	"cmds"         : [cmd],
		\	'split_output' : 1 })

endfunction

function! base#bufact#html#find_by_css_selector ()
	call base#buf#start()

perl << eof
	use Mojo::DOM;
eof

endfunction

function! base#bufact#html#db_info ()
	call base#buf#start()
	call base#buf#db_info()

endfunction

function! base#bufact#html#set_ft_php ()
	call base#buf#start()

	setlocal ft=php
endfunction

function! base#bufact#html#vh_outline ()
	call base#buf#start()
	call base#html#htw_load_buf()

	let vh_outline=''
perl << eof
	use Vim::Perl qw(VimLet);
	my $vh_outline = $HTW->vh_outline;
	VimLet('vh_outline',$vh_outline);
eof
	call base#buf#open_split({ 'text' : vh_outline })
	return 1
endfunction

function! base#bufact#html#save_to_vh ()
	call base#buf#start()
	call base#html#htw_load_buf()

	let bn = fnamemodify(b:basename,':r')

	let plugin = input('Vim plugin:','idephp','custom,base#complete#plg')
	let plgdir = base#qw#catpath('plg',plugin)

	let vhdir = base#file#catfile([ plgdir, 'help' ])
	let vhdir = input('vhdir: ', vhdir, 'file')

	let vhfile_name = bn . '.txt' 
	let vhfile_name = input('VH file: ',vhfile_name)

	let vhtag  = input('VH tag:','')
	let vhfile = base#file#catfile([ vhdir, vhfile_name ])

perl << eof
	my $vhtag  = VimVar('vhtag');
	my $vhfile = VimVar('vhfile');
	
	my $vhref = {
		out_vh_file => $vhfile,
		tag         => $vhtag,
		actions     => [qw( replace_a replace_pre )],
		xpath_rm    => [],
		xpath_cb    => [],
	};
				
	my $lines      = $HTW->save_to_vh($vhref);
eof
	call base#fileopen({ 'files': [vhfile] })
endfunction

function! base#bufact#html#db_record_delete ()
	call base#buf#start()

	if ! exists("b:db_info")
		return
	endif

	let yn = input('Delete? (1/0): ',1)
	if ! yn
		return
	endif

	let dbfile = get(b:db_info,'dbfile','')
	let table  = get(b:db_info,'table','')
	let record = get(b:db_info,'record',{})
	let rowid  = get(record,'rowid','')

	if strlen(rowid)
		let q = 'DELETE FROM ' . table . ' WHERE rowid = ? '
		let p = [ rowid ]
		let [ rows_h, cols ] = pymy#sqlite#query({
			\	'dbfile' : dbfile,
			\	'p'      : p,
			\	'q'      : q,
			\	})
	endif

endfunction

function! base#bufact#html#headings ()
	call base#buf#start()

	let lines = getline(1,'$') 
	let h     = base#html#headings({ 
			\	'lines' : lines 
			\	})

	call base#buf#open_split({ 'lines' : h })

endfunction

function! base#bufact#html#info ()
	call base#buf#start()
	call base#html#htw_load_buf()

	let inf = base#html#file_info({ 'file' : b:file })

	let d = base#dump#yaml(inf)
	call base#buf#open_split({ 'lines' : d })

endfunction

"""z_list_href
function! base#bufact#html#z_list_href (...)	
	call base#bufact#html#z_cmd_('list_href')
endfunction

function! base#bufact#html#z_list_css (...)	
	call base#bufact#html#z_cmd_('list_css')
endfunction

function! base#bufact#html#z_list_js (...)	
	call base#bufact#html#z_cmd_('list_js')
endfunction

function! base#bufact#html#z_toc_remove (...)	
	call base#bufact#html#z_cmd_('toc_remove')
endfunction

function! base#bufact#html#z_vh_outline (...)	
	call base#bufact#html#z_cmd_('vh_outline')
endfunction

"""z_vh_convert
function! base#bufact#html#z_vh_convert (...)	
	let r = {
			\	'cmds_vim' : [ 'setlocal ft=help' ],
			\	}
	call base#bufact#html#z_cmd_('vh_convert',r)
endfunction

function! base#bufact#html#z_tables_to_txt (...)	
	call base#bufact#html#z_cmd_('tables_to_txt')
endfunction

function! base#bufact#html#z_css_select (...)	
	let css  = base#input_we('css selector: ','',{})
	let opts = [ '--sel_css', css ]

	let r = { 'opts' : opts }

	call base#bufact#html#z_cmd_('css_select',r)
endfunction

function! base#bufact#html#z_cmd_ (...)
	let z_cmd = get(a:000,0,'')

	let ref   = get(a:000,1,{})
	call base#varset('z_cmd_ref',ref)

	let pl = base#qw#catpath('htmltool','bin htw.pl')

	let opts = [ '--file', shellescape(b:file), '--cmd', z_cmd ]
	call extend(opts,get(ref,'opts',[]))

	let pl_cmd = 'perl ' . pl . ' ' . join(opts,' ')

	let env = {}
	function env.get(temp_file) dict
			let ref      = base#varget('z_cmd_ref',{})
			let cmds_vim = get(ref,'cmds_vim',[])

			if filereadable(a:temp_file)
				let out = readfile(a:temp_file)
				call base#buf#open_split({ 
					\	'lines'    : out,
					\	'cmds_pre' : cmds_vim,
					\	})
			endif
	endfunction
	
	" tab_restore prevents interruption when the task completes.
	" All provided asynchandlers already use tab_restore.
	call asc#run({ 
		\	'cmd' : pl_cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})
endfunction

function! base#bufact#html#list_href ()
	call base#buf#start()
	call base#html#htw_load_buf()

	let href = base#html#list_href()

	call base#buf#open_split({ 'lines' : href })
endfunction

function! base#bufact#html#perl_html_formattext ()
	call base#buf#start()
	let lines=[]
perl << eof
	use Vim::Perl qw(:funcs :vars);
	use String::Escape qw(escape);
	use HTML::TreeBuilder;
	use HTML::FormatText;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	my $tree = HTML::TreeBuilder->new_from_content(@$lines);

	VimCmd(qq{
		let margin_left=input('Left margin:',0)
		let margin_right=input('Right margin:',100)
	});

	my $formatter = HTML::FormatText->new(
		leftmargin  => VimVar('margin_left'),
		rightmargin => VimVar('margin_right'),
	);
  my @txt = split "\n" => $formatter->format($tree);
	for(@txt){
		my $l = escape('printable',"$_");
		s/"/\\"/g;
		#VimMsg($_);
		VimCmd(qq{ call add(lines,"$l") });
	}
	
eof
	call base#buf#open_split({ 'lines' : lines })
endfunction

"""BufAct_pretty_perl_libxml
function! base#bufact#html#pretty_perl_libxml ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let load_as      = base#html#libxml_load_as()

	let html_pp = base#html#pretty_libxml({ 
			\	'htmltext' : html,
			\	'fillbuf'  : 1,
			\	'load_as'  : load_as,
			\	})

	"call base#buf#open_split({ 'lines' : html_pp })

endfunction

"""BufAct_pretty_beautifulsoup
function! base#bufact#html#pretty_beautifulsoup ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")
python << eof
		
eof

endfunction

"""bufact__select
function! base#bufact#html#_select (...)
	 let data_h = [
	 		\	{ 
	 			\	'id'   : 'a', 
	 			\	'desc' : '(xpath) select nodes between two comments',
	 			\	'xpid' : 'nodes_between_two_comments',
	 		\	}
	 		\	]
	 let headers = [ 'id', 'desc' ]
	 let tlines = pymy#data#tabulate({ 
	 		\	'data_h'  : data_h,
	 		\	'headers' : headers })

	 let msg = ''
	 let msg .= join(tlines,"\n")
	 let msg .= "\n" . 'choose id: '


	 let dbfile = base#dbfile_tmp()

	 let t = "bufact_html__select"

	 let r = {
			\	'dbfile' : dbfile,
			\	't'      : t,
			\	'c'      : [ 
							\	'id TEXT', 
							\	'desc TEXT', 
							\	'xpid TEXT' ],
			\	'rw'     : 1,
			\ }
		call pymy#sqlite#table_create(r)
		for rh in data_h
			let h = rh
			
			let ref = {
				\	'dbfile' : dbfile,
				\ "i"      : "INSERT OR REPLACE",
				\ "t"      : t,
				\ "h"      : h,
				\ }
			call pymy#sqlite#insert_hash(ref)
		endfor

		let ids = pymy#sqlite#query_as_list({
			\	'dbfile' : dbfile,
			\	'q'      : 'SELECT DISTINCT id FROM ' . t,
			\	})
		call base#varset('this',ids)
		let id = base#input_we(msg,'',{ 'complete' : 'custom,base#complete#this'})
		
		let xpid = pymy#sqlite#query_fetchone({
			\	'dbfile' : dbfile,
			\	'p'      : [id],
			\	'q'      : 'SELECT xpid FROM ' . t . ' WHERE id = ? ',
			\	})
		let xpath = base#html#xp({ 'id' : xpid })

		if xpid == 'nodes_between_two_comments'

			let begin = ''
			let end   = ''
			
			let begin = ' #BeginTocAnchorNameBegin '
			let end   = ' #EndTocAnchorNameBegin '

			let begin = base#input_we('_BEGIN_: ',begin,{})
			let end   = base#input_we('_END_: ',end,{})

			let xpath = substitute(xpath,'_BEGIN_',begin,'g')
			let xpath = substitute(xpath,'_END_',end,'g')
	 endif

	 let msg = ''
	 let msg .=  "\n" . 'XPATH to be run: '
	 let msg .=  "\n" . xpath
	 let msg .=  "\n" . 'Continue? (1/0): '

	 let yn = base#input_we(msg,1,{})
	 if !yn | return | endif

	 call base#bufact#html#xpath({ 'xpath' : xpath })

endfunction

"""bufact_xpath
function! base#bufact#html#xpath (...)
	call base#buf#start()

	let ref   = get(a:000,0,{})

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = get(ref,'xpath','')

	if ! strlen(xpath)
		let xpath = idephp#hist#input({ 
				\	'msg'  : 'XPATH:',
				\	'hist' : 'xpath',
				\	})
	endif

	"let load_as         = base#html#libxml_load_as()
	let load_as         = &ft

	let decode_entities = 1
	let cdata2text      = 0

	"let mode            = 'node_children_toString'
	let mode            = 'node_toString'

	let prompt  = input('prompt? (1/0)',0)
	if prompt
		let load_as = input('load_as (xml, html):',load_as)
	
		let decode_entities = input('Decode entities? (1/0):',decode_entities)
		let cdata2text      = input('cdata2text? (1/0):',cdata2text)
	
		let modes = base#varget('modes_html_xpath',[])
		call base#varset('this',modes)
	
		let mode = base#input_we('mode:',mode,{ 
			\ 'complete' : 'custom,base#complete#this'})
	endif

	let filtered = []
	let filtered = base#html#xpath({
				\	'htmltext'        : html,
				\	'xpath'           : xpath,
				\	'add_comments'    : 0,
				\	'cdata2text'      : cdata2text,
				\	'decode_entities' : decode_entities,
				\	'load_as'         : load_as,
				\	'mode'            : mode,
				\	})

	let lines = []

	call extend(lines,['<!-- ' ])
	call extend(lines,['   XPATH:' ])
	call extend(lines,['     ' . xpath ])
	call extend(lines,['   OPTIONS:'])
	call extend(lines,['      load_as         => ' . load_as ])
	call extend(lines,['      cdata2text      => ' . cdata2text ])
	call extend(lines,['      decode_entities => ' . decode_entities ])
	call extend(lines,['      mode            => ' . mode ])
	call extend(lines,['   '])
	call extend(lines,['   VIM CALLS:'])
	call extend(lines,['     call base#bufact#html#xpath()'])
	call extend(lines,['   '])
	call extend(lines,['   XPATH QUERY RESULT:'])
	call extend(lines,['-->'])
	call extend(lines,filtered)

	call base#buf#open_split({ 
		\ 'lines'    : lines,
		\ 'cmds_pre' : [ 'set ft=' . load_as ],
		\	})

endfunction

function! base#bufact#html#xpath_to_literal ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = idephp#hist#input({ 
			\	'msg'  : 'XPATH:',
			\	'hist' : 'xpath',
			\	})

	let filtered = []

	let load_as = base#html#libxml_load_as()

	let literal = base#html#xpath_to_literal({
				\	'htmltext'     : html,
				\	'xpath'        : xpath,
				\	})

	call base#buf#open_split({ 
		\ 'text'     : literal ,
		\ 'cmds_pre' : [ 'set ft=html' ],
		\	})

endfunction

function! base#bufact#html#quickfix_xpath ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = idephp#hist#input({ 
			\	'msg'  : 'XPATH:',
			\	'hist' : 'xpath',
			\	})

	let lines = []

	let lines = base#html#xpath_lineno({
				\	'htmltext' : html,
				\	'xpath'    : xpath,
				\	})

	for line in lines
		 let text = get(line,'text','')
		 let r = {
		 		\	'bufnr'    : bufnr('%'),
		 		\	'text'     : strpart(text,0,50),
		 		\	}
		 call extend(line,r)
	endfor
	if len(lines)
	  call setqflist(lines)	
		copen
	endif

endfunction

"""bufact_remove_extra
function! base#bufact#html#remove_extra ()
	call base#buf#start()
	call base#html#htw_load_buf()

	let xpaths = base#varget('xpaths_remove_extra',[])

	call base#bufact#html#remove_xpath({ 'xpaths' : xpaths })

endfunction

"""bufact_remove_xpath
function! base#bufact#html#remove_xpath (...)
	call base#buf#start()
	call base#html#htw_load_buf()

	let ref    = get(a:000,0,{})
	let xpath  = get(ref,'xpath','')
	let xpaths = get(ref,'xpaths',[])

	if ! len(xpaths)
		if ! strlen(xpath)
			let xpath = idephp#hist#input({ 
					\	'msg'  : 'XPATH:',
					\	'hist' : 'xpath',
					\	})
		endif
		let xpaths=[xpath]
	endif
perl << eof
	use Vim::Perl qw(:funcs :vars);

	my $xpaths = VimVar('xpaths') || [];
	my $ref    = VimVar('ref') || {};

	my $html = $HTW
		->nodes_remove({ xpaths => $xpaths })
		->htmlstr;
		
	CurBufSet({ text => $html, curbuf => $curbuf });
eof

endfunction

"""bufact_htw_load_buf
function! base#bufact#html#htw_load_buf ()
	call base#buf#start()
	call base#html#htw_load_buf()
endfunction

"""bufact_htw_node_print
function! base#bufact#html#htw_node_print ()
	call base#buf#start()
	call base#html#htw_load_buf()
	let lines=[]
perl << eof
	use String::Escape qw(escape);

	my $cmd = qq{ let xpath=input('Node xpath:','') };
	VimCmd($cmd);
	my $xpath = VimVar('xpath');

	my @lines;
	my $sub = sub{ 
		my $node = shift;
		my $line = escape('printable',$node->toString);
		VimCmd(qq{ call add(lines,"$line") });
	};
	$DOM->findnodes($xpath)->map($sub);
eof
	call base#buf#open_split({ 'lines' : lines })
endfunction



"""attr_remove
function! base#bufact#html#attr_remove ()
	call base#html#htw_load_buf()
perl << eof
	use Vim::Perl qw(:funcs :vars);

	my $xpath = '//*';
	my @nodes = $HTW->nodes({ xpath => $xpath});
	foreach my $node (@nodes) {
		my @attr = $node->attributes;
		my @names = map { $_->nodeName } @attr;
		foreach my $name (@names) {
			$node->removeAttribute($name);
		}
	}
	my $html=$HTW->htmlstr;

	CurBufSet({ text => $html, curbuf => $curbuf });
eof

endfunction

"""replace_a
function! base#bufact#html#replace_a ()
	call base#html#htw_load_buf()
perl << eof
	$HTW->replace_a;
	CurBufSet({ text => $HTW->htmlstr });
eof
endfunction

function! base#bufact#html#replace_pre ()
	call base#html#htw_load_buf()
perl << eof
	$HTW->replace_pre;
	CurBufSet({ text => $HTW->htmlstr });
eof

endfunction

"""tablenode_print
function! base#bufact#html#tables_to_txt ()
	call base#buf#start()
	call base#html#htw_init()

	let vimtext  = []

	let xpath    = input('xpath:','//table')
	let offset   = input('offset:',5)
	let maxwidth = input('maxwidth:',50)
	let fmt      = input('pack() fmt:','')

perl << eof
	my $offset   = VimVar('offset');
	my $maxwidth = VimVar('maxwidth');
	my $tblines  = VimVar('tblines');
	my $fmt      = VimVar('fmt');
	my $xpath    = VimVar('xpath');

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	$HTW
		->init_dom({ 
				htmllines => $lines 
		})
		->tables_to_txt({ 
				offset   => $offset,
				maxwidth => $maxwidth,
				fmt      => $fmt,
				xpath    => $xpath,
		})
		;

	VimLet('vimtext',$HTW->{tables_txt});
eof

	call base#buf#open_split({ 'lines' : vimtext })

endfunction

function! base#bufact#html#toc_generate ()
	call base#buf#start()
	call base#html#htw_load_buf()
perl << eof

		use Vim::Perl qw(VimVar CurBufSet);
		
		my $file = VimVar('b:file');

		use HTML::Toc;
		use HTML::TocInsertor;
		
		my $toc         = HTML::Toc->new();
		my $tocInsertor = HTML::TocInsertor->new();
		
		my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];
		my $html = join("\n",@$lines);
		
		$tocInsertor->insert($toc, $html, {'output' => \$html});

		CurBufSet({ text => $html, curbuf => $curbuf });
eof
endfunction

function! base#bufact#html#tb_to_tex ()
	call base#buf#start()
	call base#html#htw_init()

	let texlines = []

perl << eof
 use HTML::TableExtract;
 use Vim::Perl qw(VimVar);
 use String::Util qw(trim);

 my $file=VimVar('b:file');

 my $depth = VimVar('depth');
 my $count = VimVar('cnt');

 my %opts = ( depth => $depth, count => $count );
 %opts=();
 my $te = HTML::TableExtract->new( %opts );
 $te->parse_file($file);

	 # Examine all matching tables
	 my @texlines;
	 my $eol = '\\\\';
	 my $sol = '\\hline ';
	 foreach my $ts ($te->tables) {

	 	 push @texlines,
		 	' ','\\begin{longtable}{}',
			;
			#"%Table (", join(',', $ts->coords), "):\n";

	   foreach my $row ($ts->rows) {
		 		my $r = join(' & ', map { s/\n//g; trim($_); s/\s+/ /g; $_; } @$row);
				$r = $sol . $r . $eol; 
	      push @texlines, $r;
	   }

	 	 push @texlines,
		 		'\\hline', 
				'\\end{longtable}',
				' ';
	 }
	 VimListExtend('texlines',\@texlines);
eof
	call base#buf#open_split({ 
		\	'lines' : texlines, 
		\	'cmds_pre' : ['setlocal ft=tex'] 
		\	})

endfunction

function! base#bufact#html#tb_to_txt ()
	call base#buf#start()
	call base#html#htw_init()

	let lines_txt = []

	let colwidth_max = input('Max colwidth:',50)

perl << eof
 use HTML::TableExtract;
 use Vim::Perl qw(VimVar);
 use String::Util qw(trim);

 my $file = VimVar('b:file');

 my $colwidth_max = VimVar('colwidth_max');

 my %opts = ( depth => $depth, count => $count );
 %opts=();
 my $te = HTML::TableExtract->new( %opts );
 $te->parse_file($file);

 my $fmt = sub { my $r=shift; ('A'.$colwidth_max.' ') x scalar @$r; }; 

	 # Examine all matching tables
	 my @lines_txt;
	 my $delim = '-' x 50;
	 my $i=0;
	 foreach my $ts ($te->tables) {
	 	 $i++;

	 	 push @lines_txt, 
		 		'table #'.$i , $delim;

	   foreach my $row ($ts->rows) {
		 		my @r = map { s/\n//g; trim($_); s/\s+/ /g; $_; } @$row;
				my $ncols = scalar @r;
		 		my $r = pack($fmt->(\@r), @r );

	      push @lines_txt, 
						$r, $delim;
	   }
	 }
	 VimListExtend('lines_txt',\@lines_txt);
eof
	call base#buf#open_split({ 
		\	'lines' : lines_txt, 
		\	})

endfunction
