

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

function! base#buf#pathids ()
	let ids = base#pathids(b:file)

	return ids
endfunction

function! base#buf#start ()

	"if exists("b:base_buf_started") | return | endif

	let b:file     = expand('%:p')
	let b:basename = expand('%:p:t')
	let b:ext      = expand('%:p:e')
	
	let b:dirname = expand('%:p:h')
	
	let b:finfo   = base#getfileinfo()

	let b:base_buf_started=1
endfunction
