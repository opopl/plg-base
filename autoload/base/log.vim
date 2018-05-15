
function! base#log#view_split ()
	let log = base#varget('base_log',[])

	let lines=[]
	for msg in log
		call add(lines,get(msg,'msg',''))
	endfor

	call base#buf#open_split({ 'lines' : lines })
	
endfunction

function! base#log#clear ()
	call base#varset('base_log',[])
endfunction

function! base#log#cmd (...)
	let cmd = get(a:000,0,'view_split')
	let sub = 'base#log#'.cmd
	exe 'call ' . sub . '()'

endfunction
