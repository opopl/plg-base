
"if exists("s:base_sourced_cmds")
	"finish 
"endif
"l

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

"command! -nargs=* -complete=custom,base#complete#info
    "\   INFO call base#info(<f-args>)
   
""command! -nargs=* -complete=custom,base#complete#datlist VDAT 
	""\	call base#viewdat(<f-args>) 

"command! -nargs=* -complete=custom,base#complete#varlist
    "\   BaseVarUpdate call base#varupdate(<f-args>) 

"command! -nargs=* -complete=custom,base#complete#varlist
    "\   BaseVarEcho call base#varecho(<f-args>) 

"command! -nargs=* 
    "\   BaseInit call base#init() 

"command! -nargs=* -complete=custom,base#complete#datlist
    "\   BaseDatView call base#viewdat(<f-args>) 

"command! -nargs=* -complete=custom,base#complete#statuslines
    "\   StatusLine call base#statusline(<f-args>) 

