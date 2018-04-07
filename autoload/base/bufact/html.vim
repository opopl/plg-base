

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

	let lines = getline(0,'$') 
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

"""remove_xpath
function! base#bufact#html#remove_xpath ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = idephp#hist#input({ 
			\	'msg'  : 'XPATH:',
			\	'hist' : 'xpath',
			\	})

	let lines = []

	let cleaned = base#html#xpath_remove_nodes({
				\	'htmltext' : html,
				\	'xpath'    : xpath,
				\	'fillbuf'  : 1,
				\	})

endfunction

"""remove_attr
function! base#bufact#html#attr_remove ()
	call base#html#htw_load_buf()
	let load_as = base#html#libxml_load_as()
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

	$Vim::Perl::CURBUF=$curbuf;
	CurBufSet({ text => $html});
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

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = '//table'
	let lines = []

	let tblines = base#html#xpath({
				\	'htmltext' : html,
				\	'xpath'    : xpath,
				\	'fillbuf'  : 0,
				\	})

	let vimtext  = []
	let offset   = input('offset:',5)
	let maxwidth = input('maxwidth:',50)

perl << eof
	my $offset   = VimVar('offset');
	my $maxwidth = VimVar('maxwidth');
	my $tblines  = VimVar('tblines');

	$HTW
		->init_dom({ htmllines => $tblines })
		->tables_to_txt({ 
			offset   => $offset,
			maxwidth => $maxwidth,
		})
		;
	my $dbh=$HTW->{dbh_sqlite};

	VimLet('vimtext',$HTW->{tables_txt});
eof

	call base#buf#open_split({ 'lines' : vimtext })

endfunction


