
"""
function! base#image#convert (a,b)

	if !filereadable(a:a)
		return
	endif

	let exes=base#varget('exefiles',{})	

	let im_cv=get(exes,'im_convert','')
	if filereadable(im_cv)
		let cmd = join([im_cv,a:a,a:b],' ')
		call base#sys({ "cmds" : [cmd]})
	endif
	
endfunction

"call base#image#extract_info ({
   "	\	'dirs' : [dir1,dir2,...],
   "  \ })

function! base#image#extract_info (...)
	let ref=get(a:000,0,{})

	let image_dirs = get(ref,'dirs',[])
	let exts       = base#qw('jpg')

	let images = base#find({ 
		\	"dirs" : image_dirs,
		\	"exts" : exts,
		\	})

	let exes=base#varget('exefiles',{})	

	let im_idn=get(exes,'im_identify','')

	if filereadable(im_idn)
		let cmd = join([im_cv,a:a,a:b],' ')
		call base#sys({ "cmds" : [cmd]})
	endif
	
endfunction
