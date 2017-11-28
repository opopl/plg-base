
"""
function! base#image#convert (a,b)

	if !filereadable(a:a)
		return
	endif

	let exes=base#varget('exefiles',{})	

	let im_cv=get(exes,'im_convert','')
	if filereadable(im_cv)
		let cmd = join(im_cv,a:a,a:b,' ')
		call base#sys({ "cmds" : [cmd]})
	endif
	
endfunction
