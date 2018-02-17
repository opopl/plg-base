
function! base#value#var (varname)
		if exists(a:varname)
			exe 'let var='.a:varname
			return var
		else
			return ''
		endif
	
endfunction
