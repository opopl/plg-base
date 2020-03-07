
finish
let g:base_cmds_done=1
if exists("g:base_cmds_done")
	finish 
endif


command! -nargs=* -complete=custom,base#complete#vimcoms LCOM
	\ call base#loadvimcom(<f-args>)

command! -nargs=* -complete=custom,base#complete#vimcoms VCOM
	\ call base#viewvimcom(<f-args>)

command! -nargs=1 -complete=custom,base#complete#vimfuns LFUN 
	\ call base#loadvimfunc(<f-args>)

command! -nargs=1 -complete=custom,base#complete#vimfuns RFUN 
	\ call base#runvimfunc(<f-args>)

command! -nargs=1 -complete=custom,base#complete#vimfuns VFUN 
	\ call base#viewvimfunc(<f-args>)



