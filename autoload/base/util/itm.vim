
"" {
function! base#util#itm#x (...)
  let ref = get(a:000,0,{})

  let itm = get(ref,'itm',{})

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
		let oo = get(itm,o,{})
		let ooi = base#util#itm#info(oo)
		call add(data_o,[ o, ooi ] )
	endfor
	let info_o = pymy#data#tabulate ({ 
			\	'data' : data_o, 
			\	'header' : [ 'opt', 'info' ]
			\	})
	call extend(info,info_o)
	let info_txt = (len(prev) > 1 ? "\n" : '' ) . join(info, "\n")

	echo info_txt

  let d_call      = get(itm,'@call','')
  let d_code      = get(itm,'@code','')
  let d_call_args = get(itm,'@call_args',[])

  let d_sh        = get(itm,'@sh',{})
	call base#util#itm#x_sh(d_sh)
  
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

"{
function! base#util#itm#x_sh (...)
  let d_sh = get(a:000,0,{})

	if !len(d_sh) | return | endif

  "let dd_define = get(d_sh,'@define',{})
  let dd_cmd    = get(d_sh,'@cmd','')
  let dd_pathid = get(d_sh,'@pathid','')
  let dd_async  = get(d_sh,'@async',0)
  let dd_split  = get(d_sh,'@split',0)

  let dd_done  = get(d_sh,'@done',{})

  let path = base#path(dd_pathid)
  let path = isdirectory(path) ? path : getcwd() 

  let vim_cmds = get(dd_done,'@vim',[])
  let done_vcode = join(vim_cmds, "\n")

	" {
  if !dd_async
    let ok = base#sys({ 
      \  "cmds"         : [dd_cmd],
      \  "split_output" : dd_split,
      \  "start_dir"    : path,
      \  })
    let out    = base#varget('sysout',[])
    call base#buf#open_split({ 'lines' : out })
    exec done_vcode

	" }{
  else
    let env = {
      \ 'cmd'   : dd_cmd,
      \ 'split' : dd_split,
      \ 'done' : { 
          \  'vcode' : done_vcode
          \ },
      \  }

		"{
    function env.get(temp_file) dict
      let temp_file = a:temp_file
      let code      = self.return_code

      let split = get(self,'split',0)

      let done = get(self,'done',{})
      let done_vcode = get(done,'vcode','')
    
      if filereadable(a:temp_file)
        let out = readfile(a:temp_file)
        if split
          call base#buf#open_split({ 'lines' : out })
        endif
      endif

      try 
        exec done_vcode 
      catch
        call base#rdwe('[base#util#x_itm] Error executing vim code')
      endtry

    endfunction
		"} env.get
    
    call asc#run({ 
      \  'cmd' : dd_cmd, 
      \  'Fn'  : asc#tab_restore(env) 
      \  })
  endif
	"} dd_async

endfunction
"} base#util#itm#x_sh

