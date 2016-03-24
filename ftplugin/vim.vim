
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

" if we are dealing with a vim file inside plg dir
let cr = base#file#commonroot([ b:dirname, base#path('plg')] )

if strlen(cr)

	let aucmds = [ 
			\	'StatusLine plg'                        ,
			\	'TgSet thisfile'                        ,
			\	] 

	let fr = '  autocmd BufWinEnter,BufRead,BufEnter,BufWritePost '
	
	let b:ufile = base#file#win2unix(b:file)
	
	exe 'augroup base_plg_vim'
	exe '  au!'
	for cmd in aucmds
		exe join([ fr,b:ufile,cmd ],' ')
	endfor
	exe 'augroup end'
endif

