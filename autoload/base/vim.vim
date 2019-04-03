

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

function! base#vim#in_visual_mode (...)
	let m = base#qw('V v')

	return  base#inlist(mode(),m) ? 1 : 0

endfunction

function! base#vim#helptags (...)
	let ref    = get(a:000,0,{})

	let docdir = get(ref,'dir','')
	let tfile  = get(ref,'tfile','')

	let dirs   = get(ref,'dirs',[])

  if len(dirs)
		for dir in dirs
			let path  = get(dir,'path','')
			let tfile = get(dir,'tfile','')
			call base#vim#helptags({ 
				\	'dir'   : path,
				\	'tfile' : tfile
				\	})
		endfor
	endif

  if strlen(docdir)

		if ( !isdirectory(docdir) )
			return
		endif

		let ff = glob(docdir . '/*')

		if !len(ff) | return | endif

		let prf = { 
			\	'func'   : 'base#vim#helptags',
			\	'plugin' : 'base' }

		let cmd = 'helptags ' . docdir

		call base#log([ 'try: ' . cmd	],prf)

		let warn_msg=''
		try
			silent exe cmd
		catch /^Vim\%((\a\+)\)\=:E154/	
			let warn_msg = 'Vim Error E154: duplicate tag for docdir: '."\n".docdir
		catch 	
			let warn_msg = 'Errors for helptags command, docdir: '."\n".docdir
		finally
		endtry

		call extend(prf,{ 'loglevel' : 'warn' })
		if strlen(warn_msg)
			call base#log(warn_msg,prf)
		endif

		let tfile_old = base#file#catfile([ docdir, 'tags' ])
		if filereadable(tfile_old)
			if strlen(tfile)
				let dirname = fnamemodify(tfile,':p:h')
				call base#mkdir(dirname)
				call base#file#copy(tfile_old,tfile)
			endif
		endif

  endif

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


