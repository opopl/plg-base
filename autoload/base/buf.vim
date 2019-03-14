

"
function! base#buf#type(...)
		let aa=a:000
		let type = get(aa,0,'')
		if len(type)
				let b:base_buftype=type
				return type
		endif
		let type = exists("b:base_buftype") ? b:base_buftype : ''
		return type
endf

function! base#buf#act(...)
	let start = get(a:000,0,0)
	let end   = get(a:000,1,getline('$'))
	let act   = get(a:000,2,'')

	if !strlen(act) 
		if exists("b:comps_BufAct")
			let comps = b:comps_BufAct
			let act = base#getfromchoosedialog({ 
				\ 'list'        : comps,
				\ 'startopt'    : get(comps,0),
				\ 'header'      : "Available actions for BufAct are: ",
				\ 'numcols'     : 1,
				\ 'bottom'      : "Choose BufAct action by number: ",
				\ })
		endif
	endif

	if !strlen(&ft) 
		echoerr 'No filetype!'
		return 
	endif

	call base#varset('bufact_start',start)
	call base#varset('bufact_end',end)

	let acts = exists('b:comps_BufAct') ? b:comps_BufAct : []

	"if !base#inlist(act,acts)
		"return
	"endif

	let ft   = &ft
	if base#inlist(ft,base#qw('html xhtml'))
		let ft = 'html'
	endif
	let subs = []
 " if base#inlist(ft,base#qw('php html'))
		"for ff in base#qw('html php')
			"let acts_ff = acts
			"call extend(acts_ff,base#varget('comps_BufAct_'.ff,[]))
			"if base#inlist(act,acts_ff)
				"let sub  = 'base#bufact#'.ff.'#'.act
				"call add(subs,sub)
			"endif
		"endfor
   "else
	"endif

	let sub  = 'base#bufact#'.ft.'#'.act
	call add(subs,sub)

	for sub in subs
		exe 'call '. sub.'()'
	endfor

endf


"base#buf#in('plg')
"base#buf#in('plg',{ 'subdir': base#qw('base autoload') })

function! base#buf#in(...)
	let is = 0

	if a:0
		let opt = a:1
	else
		return 0
	endif

	let ref    = get(a:000,1,{})
	let subdir = get(ref,'subdir',[])
	let dir    = base#file#catfile([ base#path(opt), subdir ])

	if ! exists('b:finfo') | return 0 | endif

	if exists('b:file')
		let file=b:file
	elseif exists('b:finfo') && ( type('b:finfo') == type({}) )
		let file = get(b:finfo,'path','')
	endif

	if !strlen(file) | return 0 | endif

	let rdir = base#file#reldir(file,dir)
	if strlen(rdir)
		let is = 1
	endif

	return is

endfunction

"base#buf#open_split({ 'lines' : lines })

function! base#buf#open_split (ref)
		let ref      = a:ref

		let lines    = get(ref,'lines',[])
		let text     = get(ref,'text','')

		let cmds_pre = get(ref,'cmds_pre',[])

		if len(text)
			let textlines = split(text,"\n")
			call extend(lines,textlines)
		endif

		if !len(lines)
			return
		endif
		
		split
		enew
    setlocal buftype=nofile
    setlocal nobuflisted
    "setlocal nomodifiable
		"
		for cmd in cmds_pre
			exe cmd
		endfor

		let lnum=line('.')
		if len(lines)
			for l in lines
				call append(lnum,l)
				let lnum+=1
			endfor
		endif

endfunction

function! base#buf#pathids_str ()
	let ids = base#buf#pathids()
	return join(ids,' ')

endfunction

function! base#buf#pathid_first ()
	let ids = base#buf#pathids()
	return get(ids,0,'')

endfunction

function! base#buf#pathids ()

	if !exists("b:file")
		call base#buf#start()
	endif

	let fi = 'home hm vim vrt'
	let fis = base#qw(fi)

	let ids = base#pathids(b:file)

	call filter(ids,"! base#inlist(v:val,fis)")

	return ids
endfunction

""" used in : base#init#au()

function! base#buf#onload ()
	call base#buf#start()

	StatusLine simple

	if b:ext == 'tags'
		setf tags
	elseif b:ext == 'nsh'
		setf nsis

	elseif b:filetype == 'vim'
		if b:basename == 'html.vim'
			TgAdd perl_html
		endif

	elseif b:filetype == 'idat'
		"BufAct update_var 
	endif
	
endfunction

function! base#buf#stat ()
	call base#buf#start()
	let st = base#file#stat(b:file)

	let lines = []
	for [k,v] in items(st)
		"call add(lines,)
	endfor

endfunction

function! base#buf#insert_snip ()
	call base#buf#start()

	let ft_old = exists('g:snippet_ft') ? g:snippet_ft : ''

	let g:snippet_ft = input('snippet ft:','','custom,snipMate#complete#snips_all')

	let snip = input('snippet:','','custom,snipMate#complete#snippetNames')

	call snipMate#SnippetInsert(snip)

	let g:snippet_ft = ft_old
endfunction

function! base#buf#au_write_post ()
	call base#buf#start()

	if b:filetype == 'idat'
		BufAct update_var 
	endif
	
endfunction

function! base#buf#is_plg ()
	call base#buf#start()

	let pall     = base#varget('plugins_all',[])
	
	for plg in pall
		let plgdir   = base#qw#catpath('plg',plg)
		
		let b:cr      = base#file#commonroot([ b:dirname, plgdir ] )
		let b:belongs = ( b:cr == plgdir )
		
		if b:belongs
			 let b:plg=plg
			 break
		endif
	endfor

endfunction


function! base#buf#db_info ()
	let info = []

	if exists("b:db_info")
		let db_info = b:db_info

		let dbfile  = get(db_info,'dbfile','')
		let table   = get(db_info,'table','')

		let record  = get(db_info,'record',{})
		let rowid   = get(record,'rowid','')

		let q = 'SELECT rowid,* FROM ' . table . ' WHERE saved_file = ?'	
		let p = [ b:file ]
		let [ rows_h, cols ] = pymy#sqlite#query({
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	'p'      : p,
			\	})
		let record = get(rows_h,0,{})
		call extend(b:db_info,{ 'record' : record })

		call add(info,'DB INFO:')
		let y = base#dump#yaml(b:db_info)
		let y = base#map#add_tabs(y)
		call extend(info,y)
	endif
	call base#buf#open_split({ 'lines' : info })
endfunction


function! base#buf#start ()

	if exists("b:base_buf_started") | return | endif

	let b:file     = expand('%:p')
	let b:basename = expand('%:p:t')
	let b:ext      = expand('%:p:e')
	let b:dirname  = expand('%:p:h')
	let b:filetype = &ft
	let b:bufnr    = bufnr(0)
	
	if exists('b:finfo') | unlet b:finfo | endif

	let b:finfo   = base#getfileinfo()

	if exists('b:finfo') && type(b:finfo) == type({})
		let b:pathids  = get(b:finfo,'pathids',[])
	endif

	let b:base_buf_started=1

	call base#buf#is_plg()
endfunction
