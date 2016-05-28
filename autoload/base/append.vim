
function! base#append#splitsystem (...)
	let cmd = a:1
	let lnum = a:2

	let arr = base#splitsystem(cmd)

	let lnum=line('.')
	for line in arr
		call append(lnum,line)
		let lnum+=1
	endfor
	
endfunction
