

function! base#vimvar#get (varname,...)
	let default = get(a:000,0,'')

	if exists(a:varname)
		exe 'let l:v='.a:varname
	else
		let l:v=default
	endif
	return l:v
	
endfunction
