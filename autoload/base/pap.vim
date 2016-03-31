

function! base#pap#list()
	let pdir = base#path('phd_p')

	let files = base#find({ 
		\ "dirs" : [pdir], 
	    \ "exts" : [], 
	    \ 'pat' : '^p\.\(.*\)\.tex$', 
		\ 'relpath' : 1,
		\ "cwd" : 0 })

	let paplist=[]
	let done={}
	for f in files
		let f = substitute(f,'^p\.\(\w\+\)\..*','\1','g')
		if ! get(done,f,0)
			call add(paplist,f)
			let done[f]=1
		endif
	endfor
	let paplist=sort(paplist)

	call base#var('paplist',paplist)

	return paplist
endf

function! base#pap#import (...)

	if a:0
		let pkey = a:1
	else
		let pkey = 'LamportLATEX'
	endif

	call projs#rootcd()

	let proj = pkey
	call projs#proj#name(pkey)

	let pdir = base#path('phd_p')

	let files = base#find({ 
		\ "dirs" : [pdir], 
	    \ "exts" : [], 
	    \ 'pat' : '^p\.'.pkey, 
		\ 'relpath' : 1,
		\ "cwd" : 0 })

	let newfiles=[]
	let pats = {
		\ 'sec' : '^sec\.\(.*\)\.i',
		\ 'fig' : '^fig\.\(.*\)',
		\ 'tab' : '^tab\.\(.*\)',
		\ 'word' : '^\(\w\+\)$',
		\	}
	for f in files
		let newf=''

		"let oldf = projs#path([f])
		let oldf = base#catpath('phd_p',f)

		let t = substitute(f,'^p\.\(\w\+\)\.\(.*\)\.tex$','\2','g')

		let nop = substitute(f,'^p\.\(.*\)$','\1','g')

		if t =~ pats.sec
			let sec  = substitute(t,pats.sec,'\1','g')
			let newf = projs#secfile(sec)

		elseif t =~ pats.fig
			let fig  = substitute(t,pats.fig,'\1','g')
			let newf = projs#secfile('fig.'.fig)

		elseif t =~ pats.tab
			let tab  = substitute(t,pats.tab,'\1','g')
			let newf = projs#secfile('tab.'.tab)
		elseif t =~ pats.word
			let sec  = substitute(t,pats.word,'\1','g')
			let newf = projs#secfile(sec)
		else
			let newf = projs#path([nop])
		endif


		if strlen(newf)
			call base#file#copy(oldf,newf)
		endif
			
	endfor

	"call projs#proj#reset(proj)
	
endfunction

