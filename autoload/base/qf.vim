
function! base#qf#errors (...)
	 let list = getqflist()
	 let list = get(a:000,0,list)

	 let errors = []

	 for item in list
			let lnum = get(item,'lnum',0)
			if lnum > 0
				call add(errors,item)
			endif
	 endfor
	 return errors
	
endfunction

function! base#qf#success (...)
	 let list = getqflist()
	 let list = get(a:000,0,list)

	 let errors = base#qf#errors(list)

	 let success = (len(errors)) ? 0 : 1
	 return success
endfunction
