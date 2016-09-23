
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
