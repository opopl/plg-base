

if 0
  Usage:
    call base#grep#async({ 
      \ 'files' : files ,
      \ 'pat'   : pat   ,
      \ })
  Call tree
    Called by
endif

function! base#grep#async (...)
  let ref = get(a:000,0,{})

  let files = get(ref,'files',[])
  let pat   = get(ref,'pat','')

  let args = [ 'grep', '-iRnH -P', shellescape(pat) ]
  call extend(args, files)

  let cmd = join(args, ' ')

  let env = { 
    \ 'files' : files,
    \ 'pat'   : pat,
    \ }

  function env.get(temp_file) dict
    let code = self.return_code
  
    if filereadable(a:temp_file)
      exe 'cgetfile ' . a:temp_file
      BaseAct copen
    endif
  endfunction
  
  call asc#run({ 
    \  'cmd' : cmd, 
    \  'Fn'  : asc#tab_restore(env) 
    \  })
  
endfunction
