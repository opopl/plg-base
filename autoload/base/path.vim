
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

	call base#paths_update({
		\ pathid : path
		\	})

endfunction

function! base#path#delete (...)
	let pathid = get(a:000,0,'')

	let dbfile = base#dbfile()

	while !strlen(pathid)
		let pathid = input('Pathid: ', pathid, 'custom,base#complete#CD')
	endw

	call pymy#sqlite#query({
		\	'dbfile' : dbfile,
		\	'q'      : 'DELETE FROM paths WHERE pathid = ?',
		\	'p'      : [pathid],
		\	})

	return
endfunction
