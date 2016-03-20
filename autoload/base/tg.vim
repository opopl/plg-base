
"  base#tg#set (id)
"  base#tg#set ()
"

function! base#tg#set (...)
	if a:0 | let tgid = a:1 | endif

	let tfile = base#tg#tfile(tgid)

	if tgid     == 'ipte_ao'
	elseif tgid == 'ipte_client'
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

function! base#tg#ids (...)
	let tgids = base#var('tgids')

	return tgids

endf

function! base#tg#ids_comma (...)
	let tgids = base#tg#ids()

	return join(tgids,',')

endf


function! base#tg#tfile (...)
	if a:0 | let tgid = a:1 | endif

	let hm    = base#path('hm')
	let tdir  = base#file#catfile([ hm, 'tags' ])
	call base#mkdir(tdir)

	let tfile = base#file#catfile([ tdir, tgid . '.tags' ])

	return tfile
endf



function! base#tg#update (...)
	if a:0 | let tg = a:1 | endif

	let tfile = base#tg#tfile(tgid)

	if tgid  == 'ipte_ao'
		call base#CD(tgid)

		let libs=join( [ 
			\	ap#file#win( base#catpath(tgid,'iPTE') ), 
			\	] ," ")

		let libs.=' ' . join( base#qw("C:/Perl/site/lib  C:/Perl/lib" ), " ")

	elseif tgid == 'ipte_client'
		let id = 'ipte_lib_client'

		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'iPTE') ), 
			\	] ," ")

		let libs.=' ' . join( base#qw("C:/Perl/site/lib  C:/Perl/lib" ), " ")

	elseif tgid == 'ipte_wt'
		let id = 'ipte_lib_client'
		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'iPTE\WT') ), 
			\	ap#file#win( base#catpath(id,'iPTE\Base') ), 
			\	] ," ")

		let libs.=' ' . join( base#qw("C:/Perl/site/lib  C:/Perl/lib" ), " ")

	elseif tgid == 'perlmod'

	endif


	let cmd = 'ctags -R -o ' . ap#file#win( tfile ) . ' ' . libs

	echo "Calling: " . cmd

	let ok = base#sys( cmd )

	if ok
		redraw!
		echohl MoreMsg
		echo "CTAGS OK: " .  cmd
		echohl None

		call base#tg#set (tgid)
	endif
endfunction
