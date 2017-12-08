
function! base#vimlines#action (action,start,end,...)
	let action = a:action

	if action == 'execute'
		let lnum=a:start
		while lnum<a:end
			let line = getline(lnum)
			exe	line

			let lnum+=1
		endw
	endif

endfunction
