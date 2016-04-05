

"function! base#buf#in('ipte_lib_client')
"function! base#buf#in('ipte_ao')

function! base#buf#in(...)
	let is = 0

	if a:0
		let opt = a:1
	else
		return 0
	endif

	if ! exists('b:finfo') | return 0 | endif

	let file = get(b:finfo,'path','')

	if !strlen(file) | return 0 | endif

	let rdir = base#file#reldir(file,base#path(opt))
	if strlen(rdir)
		let is = 1
	endif

	return is

endfunction

function! base#buf#pathids_str ()
	let ids = base#buf#pathids()
	return join(ids,' ')

endfunction

function! base#buf#pathids ()
	let fi = 'home hm vim vrt'
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

	"if exists("b:base_buf_started") | return | endif

	let b:file     = expand('%:p')
	let b:basename = expand('%:p:t')
	let b:ext      = expand('%:p:e')
	
	let b:dirname = expand('%:p:h')
	
	if exists('b:finfo')
		unlet b:finfo
	endif
	let b:finfo   = base#getfileinfo()

	let b:base_buf_started=1
endfunction
