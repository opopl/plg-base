
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

	let image_dirs   = get(ref,'dirs',[])
	let image_dirids = get(ref,'dirids',[])

	let max_img_num  = get(ref,'max_img_num',-1)

	let exts       = base#qw('jpg')

	for dirid in image_dirids
		let dir = base#path(dirid)
		call add(image_dirs,dir)
	endfor

	let images = base#find({ 
		\	"dirs" : image_dirs,
		\	"exts" : exts,
		\	})

	let exes=base#varget('exefiles',{})	

	let im_idn=get(exes,'im_identify','')

	let idn_args = get(ref,'idn_args','')

	if !filereadable(im_idn)
		return 0
	endif

	let num=0
	let a_html=[]
	let do_write_html = get(ref,'write_html',0)

	if do_write_html
			call add(a_html,'<head>')
			call add(a_html,'  <body>')
			call add(a_html,'    <table>')
	endif

	for img in images
		echo 'Processing (ImageMagick identify.exe):'
		echo '   ' . img
		
		let cmd = join([im_idn,idn_args,img],' ')

		let img_unix = base#file#win2unix(img)
		let img_href = '<a href="file://'.img_unix.'">'

		call base#sys({ 
			\	"cmds"         : [cmd],
			\	"skip_errors"  : get(ref,'skip_errors',1),
			\	"split_output" : get(ref,'split_output',0),
			\	})
		let s = base#varget('sysoutstr','')

		if do_write_html
			call add(a_html,'<tr><td>'.s.'</td><td>'.img_href.'</td></tr>')
		endif

		let num+=1
		if max_img_num > -1
			if num > max_img_num | break | endif
		endif
	endfor

	if do_write_html
			call add(a_html,'    </table>')
			call add(a_html,'  </body>')
			call add(a_html,'</head>')
			
			let htmlfile=get(ref,'htmlfile','')
			if strlen(htmlfile)
				call writefile(a_html,htmlfile)
				echo 'Written HTML file:'
				echo '  ' . htmlfile
			endif
	endif
	
endfunction

function! base#image#act (...)
	let act=get(a:000,0,'')

	let imgdir = 'photos_georgia_2016'
	let dirid  = input('Images DIRID:',imgdir,'custom,base#complete#CD')

	let ref = {
			\	'dirids' : [dirid],
			\	}

	if act == 'extract_info'
		call base#image#extract_info(ref)

	elseif act == 'extract2html_exif_DateTimeOriginal'

		let htmlfile = base#qw#catpath('dirid','exif_DateTimeOriginal.html')
		call extend(ref,{
				\	"idn_args"    : '-format "%[EXIF:DateTimeOriginal]"',
				\	"max_img_num" : 0,
				\	"write_html"  : 1,
				\	"htmlfile"    : htmlfile,
				\	})
		call base#image#extract_info(ref)
	endif
	
endfunction
