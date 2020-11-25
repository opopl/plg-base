
function! base#buf#set#paste ()
	setlocal paste
	call base#rdw('setlocal paste')

endfunction


function! base#buf#set#no_paste ()
	setlocal nopaste
	call base#rdw('setlocal nopaste')

endfunction
