

if 0
  Usage:
    call base#grep#async({ 
      \ 'files' : files ,
      \ 'pat'   : pat   ,
      \ 'dir'   : dir   ,
      \ })
  Call tree
    Called by
endif

function! base#grep#async (...)
  let ref = get(a:000,0,{})

  let files = get(ref,'files',[])
<<<<<<< HEAD
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
=======
  let dir   = get(ref,'dir','')

  let pat   = get(ref,'pat','')

  let pat   = escape(pat,'#')
  let pat   = substitute(pat,'\',repeat('\',8),'g')

  let args = [ 'grep -iRnH -P', shellescape(pat) ]
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

  if strlen(dir)
    if isdirectory(dir)
      exe 'cd ' . dir
    endif
  endif
>>>>>>> 48de3e4bc7661fc39655e776551d45811abba527
  
  call asc#run({ 
    \  'cmd' : cmd, 
    \  'Fn'  : asc#tab_restore(env) 
    \  })
  
endfunction
