
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
  let dirs  = get(ref,'dirs',[])

  let exts  = get(ref,'exts','')
  let pat   = get(ref,'pat','')

  let pat   = escape(pat,'#')
  let pat   = escape(pat,'\')
  "let pat   = substitute(pat,'\',repeat('\',8),'g')

  let args = [ 'base-grep', '-i', '-p', shellescape(pat) ]

  if len(exts)
    call extend(args, [ '-e', shellescape(exts) ])
  endif

  for file in files
    call extend(args, [ '-f', shellescape(file) ] )
  endfor
  for dir in dirs
    call extend(args, [ '-d', shellescape(dir) ] )
  endfor

  let cmd = join(args, ' ')

  let env = {
    \ 'files' : files,
    \ 'pat'   : pat,
    \ }

  function env.get(temp_file) dict
    let code = self.return_code
  
    if !filereadable(a:temp_file) | return | endif

    try
      exe 'cgetfile ' . escape(a:temp_file,'\ ')
      "debug exe 'cgetfile ' . escape(a:temp_file,'\ ')
      BaseAct copen
    catch 
      call base#rdwe('error ' . v:exception)
    endtry

  endfunction

  call asc#run({ 
    \  'cmd' : cmd, 
    \  'Fn'  : asc#tab_restore(env) 
    \  })
  
endfunction
