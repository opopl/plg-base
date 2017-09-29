

"function! base#buf#in('ipte_lib_client')
"function! base#buf#in('ipte_ao')
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

		let ref   = a:ref
		let lines = get(ref,'lines',[])
		let cmds_pre  = get(ref,'cmds_pre',[])
		
		split
		enew
    setlocal buftype=nofile
    setlocal nobuflisted
    "setlocal nomodifiable

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

function! base#buf#pathids ()
	let fi = 'home hm vim vrt ipte_clients'
	let fis = base#qw(fi)

	let ids = base#pathids(b:file)

	call filter(ids,"! base#inlist(v:val,fis)")

	return ids
endfunction

function! base#buf#onload ()
	call base#buf#start()

	if b:ext == 'tags'
		setf tags
	elseif b:ext == 'nsh'
		setf nsis
	endif
	
endfunction

function! base#buf#start ()

	if exists("b:base_buf_started") | return | endif

	let b:file     = expand('%:p')
	let b:basename = expand('%:p:t')
	let b:ext      = expand('%:p:e')
	let b:dirname  = expand('%:p:h')
	let b:filetype = &ft
	
	if exists('b:finfo') | unlet b:finfo | endif

	let b:finfo   = base#getfileinfo()

	if exists('b:finfo') && type(b:finfo) == type({})
		let b:pathids  = get(b:finfo,'pathids',[])
	endif

	let b:base_buf_started=1
endfunction
