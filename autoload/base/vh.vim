
function! base#vh#number_headings ()

'<,'>perldo BEGIN {$i=0}; if(s/^(\w)/$i. $1/g){ $i++; }
	
endfunction

function! base#vh#act (...)
	let act = get(a:000,0,'')

	if strlen(act)
		let cmd = 'call base#vh#'.act.'()'
		exe cmd
	endif

endfunction
