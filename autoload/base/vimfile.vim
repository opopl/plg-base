
function! base#vimfile#source (...)
	let ref   = get(a:000,0,{})
	let files = get(ref,'files',[])

	for file in files
		if filereadable(file)
			exe 'so ' . file
		endif
	endfor
	
endfunction
