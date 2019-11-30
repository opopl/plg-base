
function! base#fun#new (...)
  let ref = get(a:000,0,{})

  let cmds = get(ref,'cmds',[])

  let s:obj = {}
  if len(cmds)
    call extend(s:obj,{ 'cmds' : cmds })
  endif

  function! s:obj.init () dict
    call base#fun#new_Fc(self)
  endfunction
  
  let Fc = s:obj.init
  return Fc
endfunction

function! base#fun#new_Fc (self)
  let self      = a:self

  let cmds = get(self,'cmds',[])
  if len(cmds)
    for cmd in cmds
      exe cmd
    endfor
  endif
  return self
endfunction
