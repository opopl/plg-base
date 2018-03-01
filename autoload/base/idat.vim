
function! base#idat#act (...)
	let act  = get(a:000,0,'')
	let idat = get(a:000,1,'')

	if !strlen(act)
		 let act = input('IDAT action:','','custom,base#complete#idat_acts')
	endif

	if !strlen(idat)
		 let act = input('IDAT :','','custom,base#complete#datlist')
	endif

	let sub = 'base#idat#'.act
	exe 'let res ='.sub .'(idat)'
	return res
	
endfunction

function! base#idat#file (...)
	let idat = get(a:000,0,'')

	let datfiles = base#varget('datfiles',{})
	let dfile    = get(datfiles,idat,'')

	return dfile
	
endfunction

function! base#idat#push (...)
	let idat  = get(a:000,0,'')
	let items = get(a:000,1,[])

	let dfile    = base#idat#file(idat)

	if !filereadable(dfile)
		return
	endif

	let lines = base#file#lines(dfile)
	if base#type(items) == 'String'
		 call add(lines,items)

	elseif base#type(ref) == 'List'
		 call extend(lines,items)
		
	endif
	call base#file#write_lines({ 
		\	'lines' : lines, 
		\	'file'  : dfile, 
		\})

endfunction
