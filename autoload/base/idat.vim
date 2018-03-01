
function! base#idat#act (...)
	let idat = get(a:000,0,'')
	let act  = get(a:000,1,'')

	if !strlen(idat)
		 let idat = input('IDAT:','','custom,base#complete#datlist')
	endif

	if !strlen(act)
		 let act = input('IDAT action:','','custom,base#complete#idat_acts')
	endif

	let sub  = 'base#idat#'.act
	let arg  = ''

	let res=''
	exe 'let res ='.sub .'(idat)'
	return res
	
endfunction

function! base#idat#file (...)
	let idat = get(a:000,0,'')

	let datfiles = base#varget('datfiles',{})
	let dfile    = get(datfiles,idat,'')

	return dfile
	
endfunction

function! base#idat#new (...)
	let idat = get(a:000,0,'')

	let datfiles = base#varget('datfiles',{})
	let dfile    = get(datfiles,idat,'')

	return dfile
	
endfunction

function! base#idat#push (...)
	let idat  = get(a:000,0,'')
	let items = get(a:000,1,[])

	let dfile = base#idat#file(idat)

	if !filereadable(dfile)
		return
	endif

	if !len(items)
		 unlet items
		 let items = input('Item(s) to be added:','')
	endif

	let lines = base#file#lines(dfile)
	if base#type(items) == 'String'
		 call add(lines,items)

	elseif base#type(items) == 'List'
		 call extend(lines,items)
		
	endif

	call base#file#write_lines({ 
		\	'lines' : lines, 
		\	'file'  : dfile, 
		\})

endfunction
