
if 0
  call base#grep#async({
    \ 'files' : files,
    \ 'pat'   : pat,
    \ 'dir'   : dir,
    \ })
endif

function! base#grep#async (...)
  let ref = get(a:000,0,{})

  let files = get(ref,'files',[])
  let pat = get(ref,'pat','')
  let dir = get(ref,'dir','')

  let cmd = printf('grep -iRnH %s',pat)

  let env = {}
  function env.get(temp_file) dict
    let code = self.return_code

    let temp_file = a:temp_file

    if filereadable(temp_file)
      exe 'cgetfile' . escape(temp_file,'\ ')
      BaseAct copen
    endif
  endfunction
  
  call asc#run({ 
    \  'cmd' : cmd, 
    \  'Fn'  : asc#tab_restore(env) 
    \  })
  
endfunction
