
let comps = base#comps#bufact('vim') 
call add(comps,'stat')

let b:comps_BufAct = comps

if exists("b:did_base_vim_ftplugin")
  finish
endif
let b:did_base_vim_ftplugin = 1

"""ftplugin_base_vim

let b:file     = expand('%:p')
let b:basename = expand('%:p:t')
let b:ext      = expand('%:p:e')

let b:dirname  = expand('%:p:h')

let b:finfo   = base#getfileinfo()

let plgdir    = base#path('plg')

" if we are dealing with a vim file inside plg dir
let b:cr      = base#file#commonroot([ b:dirname, plgdir ] )

let b:is_plgvim = ( b:cr == plgdir )

let b:is_mkvimrc_com=0
let b:is_mkvimrc_fun=0

setlocal iskeyword+=#
setlocal sw=2

let dict_funcs = base#qw#catpath('plg','base dictionaries vim funcs.txt')
let b:dicts = {
	\ 'vim_funcs' : dict_funcs,
	\	}

"exe 'setlocal tags-='.dtags

vnoremap <buffer> <LocalLeader>plc  :PerlLinesComment<CR>
vnoremap <buffer> <LocalLeader>plu  :PerlLinesUnComment<CR>
vnoremap <buffer> <LocalLeader>plc  :PerlLinesSyntaxCheck<CR>
vnoremap <buffer> <LocalLeader>plf  :PerlLinesSplitNewFile<CR>

"vnoremap <buffer> <LocalLeader>vle  :'<,'>VimLinesExecute<CR>
vnoremap <buffer> <LocalLeader>vle  :VimLinesExecute<CR>

if b:is_plgvim

	let b:relpath = base#file#removeroot(b:dirname,plgdir)
	let b:plg     = base#file#front(b:relpath)

	setlocal ts=2

	call base#tg#set("plg_".b:plg)
	StatusLine plg
	
	let b:aucmds = [ 
		\	'StatusLine plg'                            ,
		\	'call base#tg#add("plg_'.b:plg.'")'         ,
		\	] 
	
	let fr = '  autocmd BufWinEnter,BufRead,BufEnter,BufWritePost '
	
	let b:ufile = base#file#win2unix(b:file)
	
	let b:augroup=[]
	
	call add(b:augroup,'augroup base_plg_'.b:plg)
	call add(b:augroup,'  au!')
	for cmd in b:aucmds
		call add(b:augroup, join([ fr,b:ufile,cmd ],' ') )
	endfor
	cal add(b:augroup, 'augroup end' )
	
	for x in b:augroup
		exe x
	endfor

elseif b:is_mkvimrc_com
elseif b:is_mkvimrc_fun

endif
