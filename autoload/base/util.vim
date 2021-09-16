
function! base#util#dirs_from_str (...)
  let dirids_str = get(a:000, 0, '')

  let dirids_qw = split(dirids_str, \enquote{\n})
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

if 0
  called by
    projs#pdf#invoke
    projs#bld#do
endif

function! base#util#list_acts (...)
  let ref = get(a:000,0,{})

  let acts    = get(ref,'acts',[])
  let front   = get(ref,'front',[])
  let Fc      = get(ref,'Fc','')
  let desc    = get(ref,'desc',{})

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

  let r = { 
    \ 'lines'    : lines,
    \ 'cmds_pre' : ['resize 99'] ,
    \ }

  if type(Fc) == type(function('call'))
    call extend(r,{ 'Fc' : Fc })
  endif

  call base#buf#open_split(r)

endfunction

function! base#util#call_itm (...)
  let ref = get(a:000,0,{})

  let itm = get(ref,'itm',{})

  if ( type(itm) == type({}) && !len(itm)) | return | endif
  if ( type(itm) == type(v:none)) | return | endif

  let prev = get(ref,'prev',[])

  let d_call      = get(itm,'@call','')
  let d_code      = get(itm,'@code','')
  let d_call_args = get(itm,'@call_args',[])

  let d_sh        = get(itm,'@sh',{})

  if len(d_sh)
    "let dd_define = get(d_sh,'@define',{})
    let dd_cmd    = get(d_sh,'@cmd','')
    let dd_pathid = get(d_sh,'@pathid','')
    let dd_async  = get(d_sh,'@async',0)
    let dd_split  = get(d_sh,'@split',0)

    let dd_done  = get(d_sh,'@done',{})

    let path = base#path(dd_pathid)
    let path = isdirectory(path) ? path : getcwd() 

    if !dd_async
      let ok = base#sys({ 
        \  "cmds"         : [dd_cmd],
        \  "split_output" : dd_split,
        \  })
      let out    = base#varget('sysout',[])

      let vim_cmds = get(dd_done,'@vim',[])
      let vcode = join(vim_cmds, "\n")
      "call base#buf#open_split({ 'lines' : [vcode] })
      "echo vcode
      exec vcode
    else
      let env = {
        \ 'cmd'   : dd_cmd,
        \ 'split' : dd_split,
        \  }
      function env.get(temp_file) dict
        let temp_file = a:temp_file
        let code      = self.return_code

        let split = get(self,'split',0)
      
        if filereadable(a:temp_file)
          let out = readfile(a:temp_file)
          if split
            call base#buf#open_split({ 'lines' : out })
          endif
        endif
      endfunction
      
      call asc#run({ 
        \  'cmd' : dd_cmd, 
        \  'Fn'  : asc#tab_restore(env) 
        \  })
    endif
  endif

  if len(d_call)
    call call(d_call,d_call_args)
  endif

  let opts = []
  for [k,v] in items(itm)
    if k =~ '^@' | break | endif

    call add(opts,k)
  endfor

  if len(opts)
    call base#varset('this',opts)

    let msg = printf('[%s] opt: ',join(prev, '.'))
    let opt = input(msg,'','custom,base#complete#this')
    call add(prev,opt)

    let itm_r = get(itm,opt,{})
    call base#util#call_itm({ 
        \ 'itm'  : itm_r, 
        \ 'prev' : prev, 
        \ })
  endif
    
endfunction

function! base#util#call_fmt (...)
  let ref = get(a:000,0,{})

  let act      = get(ref,'act','')

  let fmt_sub  = get(ref,'fmt_sub','')
  let fmt_call = get(ref,'fmt_call','')

  let fmt_call = ''
  if len(fmt_sub)
    let sub = printf(fmt_sub, act)
    exe printf('call %s()',sub)
    return
  endif

  if len(fmt_call)
    exe printf(fmt_call, act)
  endif

endfunction

function! base#util#split_acts (...)
  let ref = get(a:000,0,{})

  let act  = get(ref,'act','')
  let acts = get(ref,'acts',[])

  let itms = get(ref,'items',{})

  let acts = sort(acts)

  let desc = get(ref,'desc',{})

  let front   = get(ref,'front',[])

  let fmt_sub = get(ref,'fmt_sub','')
  let fmt_call = get(ref,'fmt_call','')

  let Fc      = get(ref,'Fc','')

  if ! strlen(act)
    call base#util#list_acts({ 
      \ 'acts'  : acts,
      \ 'front' : front,
      \ 'desc'  : desc,
      \ 'Fc'    : Fc,
      \ })
     return
  endif

  let itm = get(itms,act,{})

  if len(itm)
    call base#util#call_itm({ 
      \ 'itm'  : itm, 
      \ 'prev' : [act], 
      \ })
  else
    call base#util#call_fmt({ 
      \ 'act'      : act,
      \ 'fmt_sub'  : fmt_sub,
      \ 'fmt_call' : fmt_call,
      \ })
  endif

endfunction

