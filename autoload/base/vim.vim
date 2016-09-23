
function! base#vim#showfun (...)
	let fun   = get(a:000,0,'')
	let lines = base#vim#linesfun(fun)

	let hist = base#varget('hist_cmds',{})
	let k    = 'BaseVimFun'
	let ch   = get(hist,k,[])

	if strlen(fun)
		call add(ch,fun)
	endif
	call extend(hist,{ k : ch })

	call base#varset('hist_cmds',hist)
	call base#text#bufsee({ 'lines' : lines })

endfunction

function! base#vim#showcom (...)
	let com   = get(a:000,0,'')
	let lines = base#vim#linescom(com)

	let hist = base#varget('hist_cmds',{})
	let k    = 'BaseVimCom'
	let ch   = get(hist,k,[])

	if strlen(com)
		call add(ch,com)
	endif
	call extend(hist,{ k : ch })

	call base#varset('hist_cmds',hist)
	call base#text#bufsee({ 'lines' : lines })
	
endfunction


function! base#vim#linesfun (...)

	let fun = get(a:000,0,'')

	redir => v
	silent exe 'verbose function '.fun
	redir END

	let lines = split(v,"\n")
	return lines
	
endfunction

function! base#vim#linescom (...)

	let com = get(a:000,0,'')

	redir => v
	silent exe 'verbose command '.com
	redir END

	let lines = split(v,"\n")
	return lines
	
endfunction


