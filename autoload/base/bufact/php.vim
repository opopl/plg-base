
function! base#bufact#php#set_ft_html ()
	call base#buf#start()
	call base#html#htw_load_buf()

	setlocal ft=html
	
endfunction


function! base#bufact#php#syntax_check ()
	call base#buf#start()
	call base#html#htw_load_buf()

	setlocal makeprg=php\ -ln\ %
	setlocal errorformat=%m\ in\ %f\ on\ line\ %l	

	AsyncMake
endfunction

function! base#bufact#php#exec_async ()
	call base#buf#start()
	call base#html#htw_load_buf()

	setlocal makeprg=php\ -n\ %
	setlocal errorformat=%m\ in\ %f\ on\ line\ %l	

	AsyncMake
endfunction

