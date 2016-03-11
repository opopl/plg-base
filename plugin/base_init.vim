
call base#initvars()

let dir = ap#file#catfile( [ expand('<sfile>:p'), '..', '..' ])
call base#var('plgdir',dir)
call base#var('datadir',ap#file#catfile([ dir, 'data' ]))

call base#init()

"command! -nargs=1 -complete=custom,base#complete#vimfuns LFUN 
  "\	call base#loadvimfunc(<f-args>)

"command! -nargs=1 -complete=custom,base#complete#vimfuns VFUN 
  "\	call base#viewvimfunc(<f-args>)

"command! -nargs=* -complete=custom,base#complete#vimcommands LCOM 
  "\	call base#loadvimcommand(<f-args>)

"command! -nargs=1 -complete=custom,base#complete#vimfuns RFUN 
  "\	call base#runvimfunc(<f-args>)

"LCOM VFUN
"LCOM RFUN

"LCOM VCOM
"LCOM VVP

"LCOM RTAGS
"LCOM STAGS

"LCOM LMK
"LCOM VDAT

"LCOM VarUpdate

"RFUN F_SetPaths

"VarUpdate vim_funcs_user

"LMK ctags.vim
"LMK docs.vim
