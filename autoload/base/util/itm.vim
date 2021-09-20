

"
"{
function! base#util#itm#x_prepare (...)
  let ref = get(a:000,0,{})

  let itm_    = base#x#get(ref,'%itm',{})
  let dd_vars = base#x#get(ref,'%vars',{})

  let d_yaml = base#x#get(ref,'@yaml',{})

  let path = base#x#getpath(itm_,'@path','')

  let yfile = base#x#get(d_yaml,'@file','')
  let ydata = base#x#get(d_yaml,'@data',{})

  let r = {
     \ '%itm'  : itm_,
     \ '%vars' : dd_vars
     \ }
  call extend(r,{ 'data' : ydata })

  let ydata = base#util#itm#expand#data(r)

  if len(path)
    let yfile = join([path,yfile], '/')
  endif

  call base#yaml#dump_fs ({
      \ 'data' : ydata,
      \ 'file' : yfile,
      \ })
  
endfunction
"} end: 

"" {
function! base#util#itm#x (...)
  let ref = get(a:000,0,{})

  let itm = get(ref,'itm',{})
  let g:a = 1

  if ( type(itm) == type({}) && !len(itm)) | return | endif
  if ( type(itm) == type(v:none)) | return | endif

  let opts = []
  for [k,v] in items(itm)
    if k =~ '^@' | continue | endif

    call add(opts,k)
  endfor

  let prev = get(ref,'prev',[])

  let d_desc    = get(itm,'@desc','')
  let d_desc_a  = base#x#list(d_desc,{ 'sep' : "\n" })
  let d_info    = get(d_desc_a,0,'')
  let info = []
  call extend(info,d_desc_a)
  "call extend(info,opts)
  let data_o = []
  for o in sort(opts)
    let oo = base#x#get(itm,o,{})
    let ooi = base#util#itm#info(oo)
    call add(data_o,[ o, ooi ] )
  endfor
  let info_o = pymy#data#tabulate ({ 
      \ 'data' : data_o, 
      \ 'header' : [ 'opt', 'info' ]
      \ })
  call extend(info,info_o)
  let info_txt = (len(prev) > 1 ? "\n" : '' ) . join(info, "\n")

  echo info_txt

  let d_call      = get(itm,'@call','')
  let d_code      = get(itm,'@code','')
  let d_call_args = get(itm,'@call_args',[])

  let d_sh        = get(itm,'@sh',{})
  if len(d_sh)
    call extend(d_sh,{ '%itm' : itm })
    call base#util#itm#x_sh(d_sh)
  endif
  
  if len(d_call)
    call call(d_call,d_call_args)
  endif

  let pref = ''
  if len(opts)
    call base#varset('this',opts)

    " input message for next level of commands
    let msg_next_a = []

    call add(msg_next_a, printf('[%s] opt: ',join(prev, '.')) )
    let msg_next = join(msg_next_a, "\n")
    let opt = input(msg_next,'','custom,base#complete#this')
    call add(prev,opt)

    let itm_r = get(itm,opt,{})
    call base#util#itm#x({ 
        \ 'itm'  : itm_r, 
        \ 'prev' : prev, 
        \ })
  endif
    
endfunction
" } base#util#itm#x
"
"{
function! base#util#itm#info (...)
  let ref = get(a:000,0,{})

  let desc = get(ref,'@desc','')
  let desc_a = base#x#list(desc,{ 'sep' : "\n" })

  let info = get(desc_a,0,'')
  return info
  
endfunction
"} end: 
"
"{
function! base#util#itm#x_sh_qflist (...)
  let ref = get(a:000,0,{})

  let d_copen    = base#x#get(ref,'@copen',0)
  let d_ln_match = base#x#get(ref,'@ln_match','')

  let out        = base#x#get(ref,'out',[])
python3 << eof
import vim,re

pat_ = '^(?P<filename>[^:]*):(?P<lnum>\d+):(?P<text>.*)$'
pat_ = vim.eval('d_ln_match') or pat_
out_ = vim.eval('out') or []

keys_ = util.qw('filename lnum text')
list_ = []
for ln in out_:
  m = re.match(rf'{pat_}',ln)
  qf = {}
  if not m:
    continue
  for k in keys_:
    val = m.group(k)
    qf.update({ k : val })
  list_.append(qf)
  
eof
  let list_ = py3eval('list_')
  call setqflist(list_)

  if d_copen
    call base#act#copen()
  endif
  
endfunction
"} end: 

"{
function! base#util#itm#x_sh (...)
  let d_sh = get(a:000,0,{})

  if !len(d_sh) | return | endif

  let itm_ = base#x#get(d_sh,'%itm',{})

  "let dd_define = get(d_sh,'@define',{})
  let dd_cmd    = base#x#get(d_sh,'@cmd','')
  let dd_pathid = base#x#get(d_sh,'@pathid','')
  let dd_async  = base#x#get(d_sh,'@async',0)

  let dd_input  = base#x#get(d_sh,'@input',{})
  let dd_prompt = base#x#get(dd_input,'@prompt',[])

  " variables to be expanded via base#sh#expand
  let dd_vars = {}
  if len(dd_pathid)
    call extend(dd_vars,{ 
      \ '@pathid' : dd_pathid 
      \ })
  endif

  for i in dd_prompt
    let var_name = base#x#get(i,'@var','')
    if !len(var_name) | continue | endif

    let comps   = base#x#get(i,'@comps',[])
    let default = base#x#get(i,'@default','')

    let msg  = printf('%s: ',var_name)
    let msg  = base#x#get(i,'@msg',msg)

    call base#varset('this',comps)

    let value = base#input_we(msg,default,{ 'this' : 1 })
    call extend(dd_vars,{ var_name : value })

  endfor

  let dd_cmd = base#sh#expand({ 
      \ 'sh'   : dd_cmd,
      \ 'vars' : dd_vars })
  let dd_cmd = base#util#itm#expand#str({ 
      \ 'str'   : dd_cmd,
      \ '%itm' :  itm_ })

  let dd_done  = base#x#get(d_sh,'@done',{})
  let dd_out   = base#x#get(dd_done,'@out',{})

  "/@done/@out/@split
  let dd_split = base#x#get(dd_out,'@split',0)

  "/@done/@out/@qflist
  let dd_qflist = base#x#get(dd_out,'@qflist',{})

  let dd_path = base#qw#catpath(dd_pathid)
  let dd_path = isdirectory(dd_path) ? dd_path : getcwd() 
  let dd_path = base#x#get(d_sh,'@path',dd_path)

  let dd_path = base#sh#expand({ 
      \ 'sh'   : dd_path,
      \ 'vars' : dd_vars })
  call extend(itm_,{ '@path' : dd_path })
 
  let dd_prep      = base#x#get(d_sh,'@prepare',{})
  call extend(dd_prep,{ '%itm' : itm_, '%vars' : dd_vars })
  call base#util#itm#x_prepare(dd_prep)

  let vim_cmds = base#x#get(dd_done,'@vim',[])
  let vim_cmds = base#x#list(vim_cmds,{ 'sep' : "\n" })

  let done_vcode = join(vim_cmds, "\n")
  let done_vcode = base#sh#expand({ 
    \ 'sh' : done_vcode, 
    \ 'vars' : dd_vars })

  " {
  if !dd_async
    let ok = base#sys({ 
      \  "cmds"         : [dd_cmd],
      \  "split_output" : dd_split,
      \  "start_dir"    : dd_path,
      \  })

    let out    = base#varget('sysout',[])

    if dd_split
      call base#buf#open_split({ 'lines' : out })
    endif

    if len(dd_qflist)
      let r_qflist = dd_qflist
      call extend(r_qflist,{ 'out' : out })
      call base#util#itm#x_sh_qflist(r_qflist)
    endif

    exec done_vcode

  " }{
  else
    let env = {
      \ 'cmd'       : dd_cmd,
      \ 'dd_split'  : dd_split,
      \ 'dd_qflist' : dd_qflist,
      \ 'done' : { 
          \  'vcode' : done_vcode
          \ },
      \  }

    "{
    function env.get(temp_file) dict
      let temp_file = a:temp_file
      let code      = self.return_code

      let dd_split = get(self,'dd_split',0)
      let dd_qflist = get(self,'dd_qflist',0)

      let done = get(self,'done',{})
      let done_vcode = get(done,'vcode','')
    
      let out = filereadable(a:temp_file) ? readfile(a:temp_file) : []
      call base#varset('sysout',out)

      if dd_split
        call base#buf#open_split({ 'lines' : out })
      endif

      if len(dd_qflist)
        let r_qflist = dd_qflist
        call extend(r_qflist,{ 'out' : out })
        call base#util#itm#x_sh_qflist(r_qflist)
      endif

      try 
        exec done_vcode 
      catch
        call base#rdwe('[base#util#x_itm] Error executing vim code')
      endtry
    endfunction
    "} env.get
    
    call asc#run({ 
      \  'cmd'  : dd_cmd,
      \  'path' : dd_path,
      \  'Fn'   : asc#tab_restore(env)
      \  })
  endif
  "} dd_async

endfunction
"} base#util#itm#x_sh

