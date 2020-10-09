
function! base#util#dirs_from_str (...)
	let dirids_str = get(a:000, 0, '')

	let dirids_qw = split(dirids_str, "\n")
	let dirs = []

	for dqw in dirids_qw
		let dqw   = base#trim(dqw)		
		let dirid = matchstr(dqw, '^\zs\w\+\ze' )
		let qw    = matchstr(dqw, '^\w\+\s\+\zs.*\ze$' )
		let qw    = base#trim( qw )
		let dir   = base#qw#catpath(dirid, qw)

		if strlen(dir) 
			call add(dirs, dir)
		endif

	endfor

	return dirs
	
endfunction

function! base#util#split_acts (...)
	let ref = get(a:000,0,{})

	let act  = get(ref,'act','')
	let acts = get(ref,'acts',[])

	let desc = get(ref,'desc',{})

	let front   = get(ref,'front',[])
	let fmt_sub = get(ref,'fmt_sub','')

	let Fc      = get(ref,'Fc','')

  if ! strlen(act)
    let info = []
    for act in acts
      call add(info,[ act, get(desc,act,'') ])
    endfor
    let lines = [ ]

    call extend(lines,front)

    call extend(lines, pymy#data#tabulate({
      \ 'data'    : info,
      \ 'headers' : [ 'act', 'description' ],
      \ }))

    call base#buf#open_split({ 
      \ 'lines'    : lines,
      \ 'cmds_pre' : ['resize 99'] ,
      \ 'Fc'       : Fc,
      \ })
    return
  endif

  let sub = printf(fmt_sub, act)
  exe printf('call %s()',sub)

endfunction
