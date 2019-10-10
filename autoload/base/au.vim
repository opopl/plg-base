
function! base#au#install (...)
	let ref = get(a:000, 0, {})

	let files   = get(ref, 'files', [])
	let aucmds  = get(ref, 'aucmds', {})
	let augroup = get(ref, 'augroup', '')
	
	exe 'augroup ' . augroup
	exe '	au!'

	for f in files
		let fu = base#file#win2unix(f)
		for [ auname, func ] in items(aucmds)
			exe 'autocmd ' . auname . ' ' . fu . ' ' . 'call ' . func . '("' . fu .'")'  
		endfor
	endfor

	exe '	augroup END'

endfunction
