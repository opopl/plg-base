
function! base#append#splitsystem (...)
	let cmd  = get(a:000,0,'')
	let lnum = get(a:000,1,line('.'))

	let arr = base#splitsystem(cmd)

	call	base#append#arr(arr,lnum)

endfunction

"base#append#arr(arr)
"base#append#arr(arr,lnum)

function! base#append#arr (...)
	let arr  = get(a:000,0,[])
	let lnum = get(a:000,1,line('.'))

	for line in arr
		call append(lnum,line)
		let lnum+=1
	endfor

endfunction

function! base#append#buf_full_path (...)
	let file = b:file
	call append(line('.'),b:file)

endfunction

function! base#append#cwd (...)
		let line=getcwd()
		let lnum=line('.')
		call append(lnum,line)
endfunction

function! base#append#env_path (...)
	let path_a=base#env#path_a()

	call base#append#arr(path_a)

endfunction
