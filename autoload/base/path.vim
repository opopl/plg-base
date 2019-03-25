
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

	let o = { 'paths_to_db' : 1 }
	call base#pathset({
		\ 'pathid' : pathid,
		\ 'path'   : path,
		\	},o)
endfunction
