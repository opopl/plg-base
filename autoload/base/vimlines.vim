
function! base#vimlines#action (action,start,end,...)
	let action = a:action

"""vimlines_execute
	if action == 'execute'
		let lnum=a:start

		let tmp   = tempname()
		let lines = []

		while lnum<a:end+1
			let line = getline(lnum)
			call add(lines,line)

			let lnum+=1
		endw
		call writefile(lines,tmp)

		let l:v = ''

		try
			redir => l:v 
			silent exe 'so ' . tmp
			redir END
		catch 
			let msg = [
				\	'action => execute',
				\	]
			let prf = {
				\	'loglevel'    : 'warn',
				\	'v_exception' : v:exception,
				\	'plugin'      : 'base',
				\	'func'        : 'base#vimlines#action'
				\	}
			call base#log(msg,prf)
		endtry
	
		let l = split(l:v,"\n")
		if len(l)
			call base#buf#open_split({ 'lines' : l })
		endif

	endif

endfunction
