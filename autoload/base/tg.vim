
"  base#tg#set (id)
"  base#tg#set ()
"

function! base#tg#set (...)
	if a:0 | let tgid = a:1 | endif

	let tfile = base#tg#tfile(tgid)

	if tgid     == 'ipte_ao'
	elseif tgid == 'ipte_client'
	elseif tgid == 'this'
	elseif tgid == 'thisfile'
	endif

	if !filereadable(tfile)
		call base#tg#update(tgid)
	endif

	exe 'set tags=' . tfile
	call base#var('tgids',[ tgid ])
	
endfunction

function! base#tg#add (...)
	if a:0 | let tgid = a:1 | endif

	let tfile = base#tg#tfile(tgid)


	exe 'set tags+=' . tfile
	let tgs = base#tg#ids() 
	call add(tgs,tgid)

	let tgs = base#uniq(tgs)

	call base#var('tgids',tgs)

endf

function! base#tg#init (...)
	let tgids = []
	call base#var('tgids',tgids)

endf

function! base#tg#ids (...)
	let tgids = base#var('tgids')

	return tgids

endf

function! base#tg#ids_comma (...)
	let tgids = base#tg#ids()

	if ( (type(tgids) == type([])) && len(tgids) )
		return join(tgids,',')
	endif
	return ''

endf


function! base#tg#tfile (...)
	if a:0 | let tgid = a:1 | endif

	let hm    = base#path('hm')
	let tdir  = base#file#catfile([ hm, 'tags' ])
	call base#mkdir(tdir)

	if tgid == 'thisfile'
		let finfo    = base#getfileinfo()
		let dirname  = get(finfo,'dirname','')
		let basename = get(finfo,'filename','')
		let tfile    = base#file#catfile([ dirname, basename . '.tags' ])
	elseif tgid == 'projs_this'
		let proj  = projs#proj#name()
		let tfile = projs#path([ proj . '.tags' ])
	else
		let tfile = base#file#catfile([ tdir, tgid . '.tags' ])
	endif


	return tfile
endf

"call base#tg#update (tgid)
"call base#tg#update ()

function! base#tg#update (...)
	if a:0 
		let tgid = a:1
	else
		let tgs = base#var('tgids')
		for tgid in tgs
			call base#tg#update(tgid)
		endfor
		return
	endif

	let tfile = base#tg#tfile(tgid)
	let libs = ''
	let files = ''

	let libs_as = join(base#qw("C:/Perl/site/lib C:/Perl/lib" ),' ')

	if tgid  == 'ipte_ao'
		call base#CD(tgid)

		let libs=join( [ 
			\	ap#file#win( base#catpath(tgid,'iPTE') ), 
			\	] ," ")

		let libs.=' ' . libs_as

"""base_tg_update_mkvimrc
	elseif tgid =~ 'mkvimrc'

		let dir = base#path('mkvimrc')
		let files_arr = base#find({ 
			\	"dirs" : [ dir ], 
			\	"exts" : [ "vim"  ], 
			\ })

		let files = join(files_arr,' ')

"""base_tg_update_plg_
	elseif tgid =~ '^plg_'
		let pat = '^plg_\(\w\+\)$'
		let plg = substitute(tgid,pat,'\1','g')

		let plgdir = base#catpath('plg',plg)

		let files_arr = base#find({ 
			\	"dirs" : [ plgdir ], 
			\	"exts" : [ "vim"  ], 
			\ })
		let files = join(files_arr,' ')

	elseif tgid == 'projs_this'
		let proj  = projs#proj#name()
		let files_arr = projs#proj#files({ 
			\	"exts" : ["tex"] ,
			\	"exclude_dirs" : [ 'joins', 'builds' ],
			\	})

		let files = join(files_arr,' ')

		let tfile = projs#path([ proj . '.tags' ])

		call projs#rootcd()

	elseif tgid == 'ipte_client'
		let id = 'ipte_lib_client'

		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'iPTE') ), 
			\	] ," ")

		let libs.=' ' . libs_as

	elseif tgid == 'ipte_wt'
		let id = 'ipte_lib_client'
		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'iPTE\WT') ), 
			\	ap#file#win( base#catpath(id,'iPTE\Base') ), 
			\	] ," ")

		let libs.=' ' . libs_as

	elseif tgid == 'perlmod'
		let id = tgid

		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'lib') ), 
			\	] ," ")

		let libs.=' ' . libs_as

"""thisfile
	elseif tgid == 'thisfile'
		let files.= ' ' . expand('%:p')
	endif

	let cmd = 'ctags -R -o ' . ap#file#win( tfile ) . ' ' . libs . ' ' . files

	echo "Calling: " . cmd
	let ok = base#sys( cmd )

	let okref = { "cmd" : cmd, "tgid" : tgid, "ok" : ok }
	call base#tg#ok(okref)

	return  ok
endfunction

function! base#tg#ok (...)
	let okref = {}
	if a:0 | let okref = a:1 | endif

	let cmd   = get(okref,'cmd','')
	let ok    = get(okref,'ok','')
	let tgid = get(okref,'tgid','')

	if ok
		redraw!
		echohl MoreMsg
		echo "CTAGS UPDATE OK: " .  tgid
		echohl None

		call base#tg#set (tgid)
	else
		redraw!
		echohl Error
		echo "CTAGS UPDATE FAIL: " .  tgid
		echohl None
	endif

	return ok
	
endfunction

function! base#tg#view (...)

	if a:0 
		let tgid = a:1
	else
		let tgs = base#var('tgids')
		for tgid in tgs
			call base#tg#view(tgid)
		endfor
		return
	endif

	let tfile = base#tg#tfile(tgid)

	if !filereadable(tfile)
		call base#tg#update(tgid)
	endif

	call base#fileopen(tfile)
	
endfunction
