
if 0
  base#ty#make

  call tree
    ----------------
    calls
      base#bat#cmd_for_exe
        base#bat#lines
        base#file#write_lines
      base#ty#make_Fc
        base#tg#ok

    ----------------
    called by
      base#tg#update
        base#tg#update_tygs
endif

function! base#ty#make (...)
  let ref = get(a:000, 0, {})

  let dirs    = get(ref, 'dirs'  ,[])
  let files   = get(ref, 'files'  ,[])

  let tfile  = get(ref, 'tfile' ,'')
  let tgid   = get(ref, 'tgid'  ,'')
  let dbfile = get(ref, 'dbfile' ,'')

  let redo        = get(ref, 'redo', 0 )
  let files_limit = get(ref, 'files_limit', 0 )

  let view_output = get(ref, 'view_output' , 0)

  let ok = 1

  let args = []
  let opts = [ 
        \ '--tfile', tfile,
        \ ]

  let ext      = has('win32') ? 'bat' : 'sh'
  let bat_file = base#qw#catpath('tmp_bat' , tgid . '.' . ext)

  for file in files
    call extend(opts, [ '--file', file ] )
  endfor

  if strlen(dbfile)
    call extend(opts, [ '--dbfile', dbfile ] )
  endif

  for dir in dirs
    call extend(opts,[ '--dir', dir ])
  endfor
  call extend(opts,[ '--action', 'generate_from_fs' ])
  call extend(opts,[ '--redo', redo ])

  if files_limit
    call extend(opts,[ '--files_limit', files_limit ])
  endif

  let ty_pl    = base#qw#catpath('htmltool', 'bin ty.pl')
  let exe_perl = get(ref, 'exe_perl', 'perl')

  if has('win32')
    let exe = join([ exe_perl, shellescape(ty_pl) ],' ' )
  else
    let exe = join([ exe_perl, ty_pl ],' ' )
  endif

  let cmd = base#bat#cmd_for_exe({ 
    \ 'opts'     : opts,
    \ 'args'     : args,
    \ 'exe'      : exe,
    \ 'bat_file' : bat_file,
    \ })

  let l:start = localtime()
  
  let env = { 
    \ 'tgid'        : tgid,
    \ 'tfile'       : tfile,
    \ 'start'       : l:start,
    \ 'view_output' : view_output,
    \ }

  function env.get(temp_file) dict
    call base#ty#make_Fc(self, temp_file)
  endfunction

  echo cmd
  return

  call asc#run({ 
    \ 'cmd' : cmd, 
    \ 'Fn'  : asc#tab_restore(env) 
    \ })

  return ok
  
endfunction

function! base#ty#make_Fc (self, temp_file)
  let temp_file = a:temp_file
  let self      = a:self

  let code = self.return_code
  let ok   = ( code == 0 ) ? 1 : 0 

  let tgid   = get(self, 'tgid', '' )
  let tfile  = get(self, 'tfile', '' )

  let l:start = get(self, 'start', '' )
  let l:end   = localtime()
  let l:el    = l:end - l:start
  let l:els   = ' ' . l:el . ' secs'

  if filereadable(a:temp_file)
    let out = readfile(a:temp_file)
    if get(self,'view_output',0)
      call base#buf#open_split({ 'lines' : out })
    endif
  endif

  let okref = { 
    \ "tgid"  : tgid,
    \ "tfile" : tfile,
    \ "ok"    : ok,
    \ "add"   : 0, 
    \ }

  let ok = base#tg#ok(okref)
endfunction
