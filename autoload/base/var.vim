
function! base#var#update (varname)
	let varname = a:varname

	if varname == 'fileids'
		let files = base#f#files()

		let fileids = sort(keys(files))
		call base#varset('fileids',fileids)
	endif

endfunction
