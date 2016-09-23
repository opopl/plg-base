
function! base#text#bufsee (...)
	let refdef = {}
	let ref    = refdef
	let refa   = get(a:000,0,{})
		
	call extend(ref,refa)
	let lines = get(ref,'lines',[])

	split | enew

	call append(0,lines)

	setlocal nomodifiable
	setlocal bufhidden
	setlocal buftype=nofile

endfunction
