
"  base#tg#set (id)
"  base#tg#set ()
"

function! base#tg#set (...)
	if a:0
		let tg = a:1
	endif

	let tfile = base#tg#tfile(tg)

	if tg     == 'ipte_ao'
	elseif tg == 'ipte_client'
	endif

	exe 'set tags=' . tfile
	call base#var('tg',tg)
	
endfunction

function! base#tg#add (...)
	if a:0
		let tg = a:1
	endif

	let tfile = base#tg#tfile(tg)

	exe 'set tags+=' . tfile

endf

function! base#tg#tfile (...)
	if a:0
		let tg = a:1
	endif

	let hm    = base#path('hm')
	let tdir  = base#file#catfile([ hm, 'tags' ])
	call base#mkdir(tdir)

	let tfile = base#file#catfile([ tdir, tg . '.tags' ])

	return tfile
endf



function! base#tg#update (...)
	if a:0
		let tg = a:1
	endif

	let tfile = base#tg#tfile(tg)


	if tg     == 'ipte_ao'
		call base#CD(tg)

		let libs=join( [ 
			\	ap#file#win( base#catpath(tg,'iPTE') ), 
			\	] ," ")

		let libs.=' ' . join( base#qw("C:/Perl/site/lib  C:/Perl/lib" ), " ")

	elseif tg == 'ipte_client'
		let id = 'ipte_lib_client'

		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'iPTE') ), 
			\	] ," ")

		let libs.=' ' . join( base#qw("C:/Perl/site/lib  C:/Perl/lib" ), " ")

	elseif tg == 'ipte_wt'
		let id = 'ipte_lib_client'
		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'iPTE\WT') ), 
			\	ap#file#win( base#catpath(id,'iPTE\Base') ), 
			\	] ," ")

		let libs.=' ' . join( base#qw("C:/Perl/site/lib  C:/Perl/lib" ), " ")

	endif


	let cmd = 'ctags -R -o ' . ap#file#win( tfile ) . ' ' . libs

	echo "Calling: " . cmd

	let ok = base#sys( cmd )

	if ok
		redraw!
		echohl MoreMsg
		echo "CTAGS OK: " .  cmd
		echohl None

		call base#tg#set (tg)
	endif
endfunction
