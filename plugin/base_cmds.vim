
command! -nargs=1  LFUN call base#loadvimfunc(<f-args>)
"
command! -nargs=* -complete=custom,base#complete#vimcommands LCOM 
	\	call base#loadvimcommand(<f-args>)
