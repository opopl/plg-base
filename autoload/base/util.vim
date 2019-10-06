
function! base#util#dirs_from_str (...)
	let dirids_str = get(a:000, 0, '')

	let dirids_qw = split(dirids_str, "\n")
	let dirs = []

	for dqw in dirids_qw
		let dqw   = base#trim(dqw)		
		let dirid = matchstr(dqw, '^\zs\w\+\ze' )
		let qw    = matchstr(dqw, '^\w\+\s\+\zs.*\ze$' )
		let qw    = base#trim( qw )
		let dir   = base#qw#catpath(dirid, qw)

		call add(dirs, dir)
	endfor

	return dirs
	
endfunction
