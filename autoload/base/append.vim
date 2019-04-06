
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

function! base#append#delim (...)
		let lnum = get(a:000,1,line('.'))

		let s = input('delim symbol:','*')
		let n = input('delim length:',50)

		let delim = repeat(s,n)
		call append(lnum,delim)

endfunction


function! base#append#csv_headers_numeric (...)

	let start = 0
	let start = input('Start header:',start)

	let end   = 10
	let end   = input('End header:',end)

	let h   = base#listnewinc(start,end,1)
	let sep = ","
	let s   = join(h,sep)

	let lnum = line('.')
	call append(lnum,s)

endfunction

function! base#append#makeprg (...)
	let lnum = line('.')
	call append(lnum,&makeprg)
endfunction

function! base#append#hist_cmd (...)
	let nrr   = input('History item range:','-1')
	let a     = split(nrr,':')
	let start = get(a,0,-1)
	let end   = get(a,1,start)

	let lnum = line('.')

	let lines = []
	let inc = ((start-end) < 0 ) ? 1 : -1
	for nr in base#listnewinc(start,end,inc)
		let hist = histget('cmd',nr)
		call add(lines,hist)
		call append(lnum,hist)
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

function! base#append#envvar (...)
  let var = input('Environment variable:','','environment')
  let val_a = base#envvar_a(var)

	call append(line('.'),val_a)

endfunction

function! base#append#env_path (...)
	let path_a=base#env#path_a()

	call base#append#arr(path_a)

endfunction
