
function! base#env#echo (...)
	let var = get(a:000,0,'')
	if !len(var) | return | endif

	if var == 'PATH'
	endif
	
	
endfunction
