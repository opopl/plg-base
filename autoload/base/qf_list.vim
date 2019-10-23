
function! base#qf_list#set (...)
	let ref = get(a:000,0,{})

	let arr = get(ref,'arr',[])

	let list = []
	for a in arr
		let item = { 'text' : a }
		call add(list,item)
	endfor

	call setqflist(list)
	
endfunction
