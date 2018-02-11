
function! base#log#view_split ()
	let log = base#varget('base_log',[])

	let lines=[]
	for msg in log
		call add(lines,get(msg,'msg',''))
	endfor

	call base#buf#open_split({ 'lines' : lines })
	
endfunction
