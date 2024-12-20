
if 0
  call tree
    calls
      base#bat#lines
      base#file#write_lines
    called by
      base#tg#update
        base#tg#update_tygs
          base#ty#make
endif

function! base#bat#cmd_for_exe (...)
  let ref      = get(a:000, 0, {})

  let bat_file = get(ref, 'bat_file' ,'')

  if !strlen(bat_file)
    return
  endif

  let blines   = base#bat#lines(ref)

  let r_f = {
    \ 'lines' : blines,
    \ 'file'  : bat_file,
    \ }

  call base#file#write_lines(r_f)
  if has('unix')
    call system(printf("chmod +rx %s",shellescape(bat_file) ))
  endif

  if !filereadable(bat_file)
    let msg = [ 'bat_file NOT exist' , bat_file ]
    let w = { 'text' : msg, 'plugin' : 'base', 'func' : 'base#bat#cmd_for_exe' }
    call base#warn(w)
    return ''
  endif

  let cmd = shellescape( bat_file )
  return cmd

endf

function! base#bat#exe_async (...)
  let ref = get(a:000,0,{})

  let cmd = base#bat#cmd_for_exe(ref)

  if !strlen(cmd)
    let msg = [ 'no cmd provided!' ]
    let w = { 'text' : msg, 'plugin' : 'base', 'func' : 'base#bat#exe_async' }
    call base#warn(w)
    return 
  endif

  let env = get(ref, 'env', {} )
  function env.get(temp_file) dict
    let code = self.return_code
  
    if filereadable(a:temp_file)
      let out = readfile(a:temp_file)
    endif
  endfunction
  
  call asc#run({ 
    \ 'cmd' : execmd, 
    \ 'Fn'  : asc#tab_restore(env) 
    \ })

  return 1

endf

function! base#bat#exe (...)
  let ref = get(a:000,0,{})

  let cmd = base#bat#cmd_for_exe(ref)

  if !strlen(cmd)
    let msg = [ 'no cmd provided!' ]
    let w = { 'text' : msg, 'plugin' : 'base', 'func' : 'base#bat#exe' }
    call base#warn(w)
    return 
  endif

  let ok = base#sys({ 
    \ "cmds"         : [cmd],
    \ "split_output" : 0,
    \ })
  let out    = base#varget('sysout',[])
  
  let res = {
    \   'out'    : out,
    \   'ok'     : ok,
    \   'cmd'    : cmd,
    \ }

  return res

endf

"
if 0
    Usage:
      let ref = {
        \ 'exe'  : exe,
        \ 'args' : [ 'a', 'b' ],
        \ 'opts' : [ '--x', 'y' ],
        \ }
    
      let lines = base#bat#lines (ref)
    
    Called by 
endif

function! base#bat#lines (...)
  let ref      = get(a:000, 0, {})

  let exe = get(ref,'exe','')

  let args = get(ref,'args',[])
  let opts = get(ref,'opts',[])

  let bat_lines = []
  if has('win32')
    let bat_lines = [
      \     ' ',
      \     '@echo off ',
      \     ' ',
      \     'REM generated by vim: base#bat#lines()' ,
      \     ' ',
      \     'set opts=',
      \     'set args=',
      \     ' ',
      \   ]
  else
   let bat_lines = [
      \     '#!/bin/bash',
      \     ' ',
      \     '# generated by vim: base#bat#lines()' ,
      \     ' ',
      \     'opts=',
      \     'args=',
      \     ' ',
      \   ]
  endif

  let i = 0
  while i < len(opts)
    if has('win32')
	    let opts[i+1] = shellescape( opts[i+1] )
	    let o         = join([ opts[i], opts[i+1] ]," ")

      call add(bat_lines,'set opts=%opts% ' . o )

    else
	    let o = join([ opts[i], opts[i+1] ]," ")
      call add(bat_lines,printf('opts="$opts %s"', o))

    endif

    let i += 2
  endw
  call add(bat_lines,' ')

  for arg in args
    if has('win32')
      call add(bat_lines,'set args=%args% ' . shellescape(arg) )
    else
      call add(bat_lines,printf('set args="$args %s"', arg) )
    endif
  endfor

  if has('win32')
    call add(bat_lines,' ')
    call add(bat_lines,'set exe=' . exe )
    call add(bat_lines,' ')
    call add(bat_lines,'cmd /c %exe% %opts% %args% %* ')
    call add(bat_lines,' ')
  else
    call add(bat_lines,' ')
    call add(bat_lines,printf('exe="%s"', exe ))
    call add(bat_lines,' ')
    call add(bat_lines,'$exe $opts $args $*')
    call add(bat_lines,' ')
  endif

  return bat_lines

endf
