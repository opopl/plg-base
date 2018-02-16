
function! base#value#var (varname)
		if exists(varname)
			exe 'let var='.varname
			return var
		else
			return ''
		endif
	
endfunction
