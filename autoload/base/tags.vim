
function! base#tags#view ()
	let files = tagfiles()

	for f in files
		if filereadable(f)
			call base#fileopen(f)
			call base#tags#set(f)
			exe 'autocmd! BufRead,BufWinEnter ' . f . ' TgSet _thisfile_'
		endif
	endfor
endfunction

function! base#tags#set (...)
	let f = get(a:000,0,'')
	if ! strlen(f) | return | endif

	let f = escape(f,' ')

	exe 'setlocal tags='.f

endfunction

function! base#tags#add (...)
	let f = get(a:000,0,'')
	if ! strlen(f) | return | endif

	let f = escape(f,' ')

	exe 'setlocal tags+='.f

endfunction
