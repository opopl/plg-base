
function! base#path#echo (pathid)
	echo base#path(a:pathid)
endfunction

function! base#path#add (...)
	let pathid = ''
	let path   = ''

	while !strlen(pathid)
		let pathid = input('Pathid: ',pathid,'custom,base#complete#CD')
	endw

	while !strlen(path)
		let path   = input('Path: '  ,path,'file')
	endw

	call base#pathset_db({
		\ pathid : path
		\	})
endfunction
