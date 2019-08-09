
function! base#time#now ()
	let date = strftime('%H:%M:%S %d-%m-%y',localtime() )
	return date
endfunction
