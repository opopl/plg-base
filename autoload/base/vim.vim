
function! base#vim#showfun (...)

	let fun = get(a:000,0,'')

	redir => v
	silent exe 'verbose function '.fun
	redir END

	split
	enew

	call append(0,split(v,"\n"))

	setlocal nomodifiable
	setlocal bufhidden
	setlocal buftype=nofile
	
endfunction

function! base#vim#showcom (...)

	let com = get(a:000,0,'')

	redir => v
	silent exe 'verbose command '.com
	redir END

	split
	enew

	call append(0,split(v,"\n"))

	setlocal nomodifiable
	setlocal bufhidden
	setlocal buftype=nofile
	
endfunction
