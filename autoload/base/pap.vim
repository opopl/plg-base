

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

function! base#envvarlist ()
	call base#envvars()
	let evlist = base#var('evlist')

	return evlist

endfunction


function! base#envvars ()

	 if has('win32')
		 call base#sys({ "cmds" : [ 'env' ]})
		 let sysout = base#var('sysout')
	
		 let ev={}
		 let pats = {
		 	\ 'ev' : '\(\w\+\)=\(.*\)$',
			\ }
		 for l in sysout
			if l =~ pats.ev
				let vname = substitute(l,pats.ev,'\1','g')
				let val   = substitute(l,pats.ev,'\2','g')
				call extend(ev,{ vname : val })
			endif
		 endfor
	 endif

	 let evlist = sort(keys(ev))
	 call base#var('ev',ev)
	 call base#var('evlist',evlist)

	 return ev

endfunction

"call base#grep({ "pat" : pat, "files" : [ ... ]  })
"call base#grep({ "pat" : pat, "files" : files })
"
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'plg_findstr' })
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'grep' }) - todo 
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'vimgrep' }) -todo

function! base#grep (...)
	let ref = {}
	if a:0 | let ref = a:1 | endif

	let opt = base#grepopt()

	let pat   = get(ref,'pat','')
	let files = get(ref,'files',[])
	let opt   = get(ref,'opt',opt)

	let rootdir = get(ref,'rootdir','')

	if strlen(rootdir)
		call map(files,'base#file#catfile([ rootdir, v:val ])')
	endif

	if opt == 'plg_findstr'

		let gref = {
			\  "files"       : files,
			\  "pat"         : pat,
			\  "cmd_name"    : 'Rfindpattern',
			\  "findstr_opt" : '/i',
			\  "cmd_opt"     : '/R /S',
			\  "use_startdir"  : 0,
			\}

		let cmd = 'call findstr#ap#run(gref)'

	elseif opt == 'vimgrep'
		let cmd = 'vimgrep /'.pat.'/ '. join(files,' ') 
	endif

	exe cmd
	
endfunction

function! base#grepopt (...)
	if ! base#varexists('grepopt')
		if has('win32')
			let opt = 'plg_findstr'
		else
			let opt = 'grep'
		endif
	else
		let opt = base#var('grepopt')
	endif

	if a:0 | let opt = a:1 | endif
	call base#var('grepopt',opt)

	return base#var('grepopt')
endfunction
 
