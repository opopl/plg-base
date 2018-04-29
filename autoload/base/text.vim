
function! base#text#bufsee (...)
	let refdef = {}
	let ref    = refdef
	let refa   = get(a:000,0,{})
		
	call extend(ref,refa)

	let lines = get(ref,'lines',[])
	let cmds  = get(ref,'cmds',[])

	split | enew

	call append(0,lines)

	setlocal nomodifiable
	setlocal bufhidden
	setlocal buftype=nofile

	for cmd in cmds
		exe cmd
	endfor

endfunction

function! base#text#table (...)
	let ref    = get(a:000,0,{})
	let data   = get(ref,'data',[])
	let header = get(ref,'header',[])

perl << eof
	use Vim::Perl qw(VimVar);
	use Text::TabularDisplay;
	our $data = [ VimVar('data') ]; our $header = [ VimVar('header') ];

	my $t = Text::TabularDisplay->new(@$header);
	foreach my $row (@$data) {
		$t->add(@$row);
	}
	return $t->render;
eof
endfunction

function! base#text#append (...)
	let refdef = {}
	let ref    = refdef
	let refa   = get(a:000,0,{})
		
	call extend(ref,refa)

	let lines = get(ref,'lines',[])

	call append(line('.'),lines)

	for cmd in cmds
		exe cmd
	endfor

endfunction
