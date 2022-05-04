
"{
function! base#dir#move (old,new)
 if !isdirectory(a:old)
    call base#warn({ 'text' : 'Old directory does not exist:'."\n\t" . a:old })
    return 
  endif
  let cmd = ''
  if has('win32')
    let cmd = 'move ' . '"'.a:old.'"' . ' ' . '"'.a:new.'"'
  else
		let cmd = printf('mv "%s" "%s"', a:old, a:new)
  endif

  if !strlen(cmd)
    return 
  endif

  let ok = base#sys({ "cmds" : [cmd]})

  return ok
	
endfunction
"} end: 
