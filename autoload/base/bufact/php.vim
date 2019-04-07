function! base#bufact#php#set_ft_html ()
	call base#buf#start()
	call base#html#htw_load_buf()

	setlocal ft=html
	
endfunction

