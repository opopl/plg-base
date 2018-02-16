function! base#info#dbext ()
	let varnames = base#varget('varnames_dbext',[])

	for varname in varnames
		let val = base#value#var(varname)
		echo val
		echo varname
	endfor
	
endfunction
