
function! base#view#lines (...)

		let lines = a:1
	
    split
    enew

    call append(0,lines)

    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nomodifiable

endfunction
