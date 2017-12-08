
function! base#vimlines#action (action,start,end,...)
	let action = a:action

	if action == 'execute'
		let lnum=a:start

		redir => v
		while lnum<a:end+1
			let line = getline(lnum)
			silent exe	line

			let lnum+=1
		endw
		redir END
	endif

	if 0
		echo 2
		echo 3
	endif
	
	let l=split(v,"\n")
	call base#buf#open_split({ 'lines' : l })

endfunction
