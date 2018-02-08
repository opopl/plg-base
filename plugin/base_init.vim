
let g:base_init_done=1
if exists("g:base_init_done")
	finish
endif

let dir = base#file#catfile( [ expand('<sfile>:p:r'), '..', '..' ])

let dir = base#file#std(dir)

call base#varset('plgdir',dir)
call base#datadir( base#file#catfile([ dir, 'data' ]) )

call base#init()


