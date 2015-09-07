
command! -nargs=1 -complete=custom,base#complete#vimfuns LFUN 
	\	call base#loadvimfunc(<f-args>)
"
command! -nargs=* -complete=custom,base#complete#vimcommands LCOM 
	\	call base#loadvimcommand(<f-args>)

command! -nargs=*  RFUN call base#runvimfunc(<f-args>)
