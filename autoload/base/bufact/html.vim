"""BufAct_lynx_dump_split
function! base#bufact#html#lynx_dump_split ()
	call base#buf#start()

	let lines = getline(0,'$') 
	let tmp   = tempname()
	call writefile(lines,tmp)

	let cmd = 'lynx -dump -force_html '.tmp
	let cmd = input('Conversion cmd:',cmd)

	echo tmp
	call base#sys({ "cmds" : [cmd], 'split_output' : 1 })

endfunction

function! base#bufact#html#headings ()
	call base#buf#start()

	let lines = getline(1,'$') 
	let h     = base#html#headings({ 
			\	'lines' : lines 
			\	})

	call base#buf#open_split({ 'lines' : h })

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
		VimCmd(qq{ call add(lines,"$_") });
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

	let html_pp=base#html#pretty_libxml({ 
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

function! base#bufact#html#xpath ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = idephp#hist#input({ 
			\	'msg'  : 'XPATH:',
			\	'hist' : 'xpath',
			\	})

	let filtered = []

	let load_as = base#html#libxml_load_as()

	let filtered = base#html#xpath({
				\	'htmltext'     : html,
				\	'xpath'        : xpath,
				\	'add_comments' : 0,
				\	'cdata2text'   : 1,
				\	'load_as'      : load_as,
				\	})

	call base#buf#open_split({ 'lines' : filtered })

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
	let xpaths = [] 
	call add(xpaths,'//script') 
	call add(xpaths,'//link') 
	call add(xpaths,'//meta') 

	call add(xpaths,"//meta[not(translate(@http-equiv,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='content-type')]")

	call add(xpaths,"//meta[not(contains(translate(@content,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'text/html; charset=utf-8'))]")

""<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	call add(xpaths,'//style') 

	call add(xpaths,"//*[@id='footer']") 
	call add(xpaths,"//*[@id='topnav']") 
	call add(xpaths,"//*[@id='sidenav']") 
	call add(xpaths,"//*[@id='googleSearch']") 
	call add(xpaths,"//*[@id='google_translate_element']") 

	call add(xpaths,"//*[@class='sidesection']") 

	call base#bufact#html#remove_xpath({ 'xpaths' : xpaths })

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

"""attr_remove
function! base#bufact#html#attr_remove ()
	call base#html#htw_load_buf()
perl << eof
	use Vim::Perl qw(:funcs :vars);

	my $xpath = '//*';
	my @nodes=$HTW->nodes({ xpath => $xpath});
	foreach my $node (@nodes) {
		my @attr = $node->findnodes('./attribute::*');
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
	my $dbh=$HTW->{dbh_sqlite};

	VimLet('vimtext',$HTW->{tables_txt});
eof

	call base#buf#open_split({ 'lines' : vimtext })

endfunction


