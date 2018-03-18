

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

"""table_to_txt
function! base#bufact#html#table_to_txt ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = '//table'
	let lines = []

	let tblines = base#html#xpath({
				\	'htmltext' : html,
				\	'xpath'    : xpath,
				\	'fillbuf'  : 0,
				\	})

	let vimtext=[]
perl << eof
	my $tblines         = VimVar('tblines');
	$HTW
		->init_dom({ htmllines => $tblines })
		;

	my @tables=$HTW->nodes({ 
		xpath => '//table' 
	});
	my $table_id   = 0;
	my $perltables = {};
	foreach my $table (@tables) {
		my $perltable=[];

		my @tr = $table->findnodes('.//tr');

		foreach my $row (@tr) {
			my $perlrow=[];
			my @td = $row->findnodes('.//td');
			foreach my $cell (@td) {
				for my $subcell($cell->findnodes('.//*')){
					my $lref = {
						node            => $subcell,
						text_callbacks  => [],
						encode_entities => 0,
						etags           => [qw(br)],
					};
					$HTW->node_replace_with_textContent($lref);
				}
				my $celltext=$cell->textContent;
				push @$perlrow,$celltext;
			}
			push @$perltable,$perlrow;
		}

		$table_id++;
		$perltables->{$table_id}={ data => $perltable };
	}

	my @ids=sort keys %$perltables;
	my @vimtext;
	foreach my $id (@ids) {
		my $data = $perltables->{$id}->{data}; 
		foreach my $row (@$data) {
			my $n=scalar @$row;
			my $fmt = 'A30' x $n;
			my $s = pack($fmt,@$row);
			push @vimtext,$s;
		}
	}

	VimLet('vimtext',\@vimtext);
eof

	call base#buf#open_split({ 'lines' : vimtext })

endfunction


