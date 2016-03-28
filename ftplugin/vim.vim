
if exists("b:did_base_vim_ftplugin")
  finish
endif
let b:did_base_vim_ftplugin = 1

let b:file     = expand('%:p')
let b:basename = expand('%:p:t')
let b:ext      = expand('%:p:e')

let b:root    = projs#root()
let b:dirname = expand('%:p:h')

let b:finfo   = base#getfileinfo()

let plgdir    = base#path('plg')

" if we are dealing with a vim file inside plg dir
let b:cr      = base#file#commonroot([ b:dirname, plgdir ] )

let b:is_plgvim = ( b:cr == plgdir )

if !b:is_plgvim
	finish
endif

let b:relpath = base#file#removeroot(b:dirname,plgdir)
let b:plg     = base#file#front(b:relpath)

let b:aucmds = [ 
	\	'StatusLine plg'                        ,
	\	'call base#tg#set("plg_'.b:plg.'")'         ,
	\	] 

let fr = '  autocmd BufWinEnter,BufRead,BufEnter,BufWritePost '

let b:ufile = base#file#win2unix(b:file)

exe 'augroup base_plg_vim'
exe '  au!'
for cmd in b:aucmds
	exe join([ fr,b:ufile,cmd ],' ')
endfor
exe 'augroup end'
