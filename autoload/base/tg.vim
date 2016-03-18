
"  base#tg#set (id)
"  base#tg#set ()
"

function! base#tg#set (...)
	if a:0
		let tg = a:1
	endif

	let hm    = base#path('hm')
	let tdir  = base#file#catfile([ hm, 'tags' ])
	let tfile = base#file#catfile([ tdir, tg . '.tags' ])

	if tg     == 'ipte_ao'
	elseif tg == 'ipte_client'
	endif
	
endfunction

function! base#tg#update (...)
	if a:0
		let tg = a:1
	endif

	let hm    = base#path('hm')
	let tdir  = base#file#catfile([ hm, 'tags' ])
	let tfile = base#file#catfile([ tdir, tg . '.tags' ])

	if tg     == 'ipte_ao'
		call base#CD('ipte_ao')
	elseif tg == 'ipte_client'
		call base#CD('ipte_lib_client')
	endif

   " let cmd    = 'dir *.pl *.pm /b/s/a:-d' 
	"let files  = split(system(cmd),"\n")
	"let cmd    = 'ctags -R --language-force=Perl ' . join(files,' ') 
			"\	 . ' -f ' . ap#file#win( tfile )
	"echo system(cmd)

	let libs=join( [ 
		\	ap#file#win( base#catpath('ipte_lib_client','iPTE') ), 
		\	] ," ")

	let libs.=' ' . join( ap#perl#inc(), " ")
	let cmd = 'ctags -R -o ' . ap#file#win( tfile ) . ' ' . libs

	call ipte#system( cmd )
endfunction
