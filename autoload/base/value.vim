
function! base#value#var (...)
	let varname = get(a:000,0,'')
	let default = get(a:000,1,'')

	if exists(varname)
		return eval(varname)
	else
		return default
	endif
	
endfunction
