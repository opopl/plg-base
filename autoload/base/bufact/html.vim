"""BufAct_lynx_dump_split
function! base#bufact#html#lynx_dump_split ()
	call base#buf#start()

	let lines = getline(0,'$') 
	let tmp   = tempname()
	call writefile(lines,tmp)
	let cmd = 'lynx -dump -force_html '.tmp
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

"""BufAct_pretty_libxml
function! base#bufact#html#pretty_libxml ()
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

"""remove_extra
function! base#bufact#html#remove_extra ()
	let xpaths = [] 
	call add(xpaths,'//script') 
	call add(xpaths,'//link') 
	call add(xpaths,'//meta') 
	call add(xpaths,'//style') 

	call add(xpaths,"//*[@id='footer']") 
	call add(xpaths,"//*[@id='topnav']") 
	call add(xpaths,"//*[@id='sidenav']") 
	call add(xpaths,"//*[@id='googleSearch']") 
	call add(xpaths,"//*[@id='google_translate_element']") 

	call add(xpaths,"//*[@class='sidesection']") 

	call base#bufact#html#remove_xpath({ 'xpaths' : xpaths })

endfunction

"""remove_xpath
function! base#bufact#html#remove_xpath (...)
	call base#buf#start()
	call base#html#htw_load_buf()

	let ref    = get(a:000,0,{})
	let xpath  = get(ref,'xpath','')
	let xpaths = get(ref,'xpaths',[])

	if len(xpaths)
		for xpath in xpaths
			call base#bufact#html#remove_xpath({ 'xpath' : xpath })
		endfor
		return
	endif

	if ! strlen(xpath)
		let xpath = idephp#hist#input({ 
				\	'msg'  : 'XPATH:',
				\	'hist' : 'xpath',
				\	})
	endif
perl << eof
	use Vim::Perl qw(:funcs :vars);

	my $xpath = VimVar('xpath') || '';
	my $ref   = VimVar('ref') || {};

	my $html = $HTW
		->nodes_remove({ xpath => $xpath })
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

"""table_to_txt
function! base#bufact#html#table_to_txt ()
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


