

function! base#cmd#FIND (...)
	let opt = get(a:000,0,'')

	if opt == 'dirid_pattern'
		let dirid   = input('DIRID:','','custom,base#complete#CD')
		let pattern = input('Pattern:','')
	endif
	
endfunction
tag base#find
