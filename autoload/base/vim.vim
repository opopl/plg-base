

"""used in BaseVimFun

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
	call base#text#bufsee({ 
		\ 'lines' : lines,
		\ 'cmds' : [ 
			\	'setf vim',
			\	'TgAdd plg',
			\	],
		\ })

endfunction

"""used in BaseVimCom

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
	call base#text#bufsee({ 
		\ 'lines' : lines,
		\ 'cmds' : [ 
			\	'setf vim',
			\	'TgAdd plg',
			\	],
		\ })
	
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

"https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! base#vim#visual_selection (...)
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end]     = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)

    if len(lines) == 0
        return ''
    endif

    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
		return lines
    "return join(lines, "\n")
endfunction

function! base#vim#list_coms (...)
	let pat = get(a:000,0,'')

	redir => v
	silent exe 'command '.pat
	redir END

	let lines = split(v,"\n")
	return lines

endfunction


