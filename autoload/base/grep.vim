
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
      try
	      exe 'cgetfile ' . escape(temp_file,'\ ')
	      BaseAct copen
      catch 
        call base#rdw('error ' . v:exception)
      endtry
    endif
  endfunction
  
  call asc#run({ 
    \  'cmd' : cmd, 
    \  'Fn'  : asc#tab_restore(env) 
    \  })
  
endfunction
