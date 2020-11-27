
function! base#buf#set#paste ()
	setlocal paste
	call base#rdw('setlocal paste')

endfunction


function! base#buf#set#nopaste ()
	setlocal nopaste
	call base#rdw('setlocal nopaste')

endfunction
