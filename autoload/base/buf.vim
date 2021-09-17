
function! base#buf#type(...)
    let aa=a:000
    let type = get(aa,0,'')
    if len(type)
        let b:base_buftype = type
        return type
    endif
    let type = exists("b:base_buftype") ? b:base_buftype : ''
    return type
endf

function! base#buf#tabs_nice(...)
  try
      let spaces =  repeat('\s', &ts)
      exe '%s/^' . spaces . '/\t/g'

      %s/\([\t]\+\)\s*/\1/g
  catch 
      echo v:exception
  endtry
endf

function! base#buf#cut(...)
  let ref = get(a:000,0,{})

  let start = get(ref, 'start', 1)
  let end   = get(ref, 'end', line('$'))

  let nums  = get(ref,'nums',[])

  if has_key(ref,'start') && has_key(ref,'end')
    exe printf('%s,%s delete',start,end)
  endif
endf

function! base#buf#lines(...)
  let start = get(a:000,0,1)
  let end   = get(a:000,1,line('$'))
  let lines = []
  let lnum  = start

  while lnum < end + 1
     let line = getline(lnum)
     call add(lines,line)
  
     let lnum+=1
  endw

  return lines
endf

function! base#buf#lines_hi(...)
  let ref = get(a:000,0,{})

  let hl = get(ref,'hl','Search')
  let lnum = line('.')
  let id =  matchadd(hl, '\%' . lnum . 'l')
  if ! exists('b:match_ids')
    let b:match_ids = {}
    call extend(b:match_ids,{ id : lnum })
  endif
endf

function! base#buf#act(...)
  let start = get(a:000,0,0)
  let end   = get(a:000,1,getline('$'))
  let act   = get(a:000,2,'')

  if !exists("b:comps_BufAct")
    return
  endif

  let acts = sort(b:comps_BufAct)

  if ! strlen(act)
    let desc = base#varget('desc_BufAct',{})
    let info = []
    for act in acts
      call add(info,[ act, get(desc,act,'') ])
    endfor
    let lines = [ 'Possible BufAct actions: ' ]
    call extend(lines, pymy#data#tabulate({
      \ 'data'    : info,
      \ 'headers' : [ 'act', 'description' ],
      \ }))

    call base#buf#open_split({ 'lines' : lines })
    return
  endif

  if !strlen(&ft) 
    echoerr 'No filetype!'
    return 
  endif

  call base#varset('bufact_start',start)
  call base#varset('bufact_end',end)

  let ft   = &ft
  if base#inlist(ft,base#qw('html xhtml'))
    let ft = 'html'
  endif
  let subs = []
  let sub = ''
  if base#inlist(act, base#comps#bufact_common() )
    let sub  = 'base#bufact_common#'.act

  elseif base#inlist(act, base#comps#bufact_scp() )
    let sub  = 'base#bufact_scp#'.act

  else
    let sub  = 'base#bufact#'.ft.'#'.act

  endif

  call add(subs,sub)

  for sub in subs
    exe 'call '. sub.'()'
  endfor

endf

"base#buf#in('plg')
"base#buf#in('plg',{ 'subdir': base#qw('base autoload') })
"
function! base#buf#terminal(...)
  call ap#GoToFileLocation()
  terminal
endf

function! base#buf#in(...)
  let is = 0

  if a:0
    let opt = a:1
  else
    return 0
  endif

  let ref    = get(a:000,1,{})
  let subdir = get(ref,'subdir',[])
  let dir    = base#file#catfile([ base#path(opt), subdir ])

  if ! exists('b:finfo') | return 0 | endif

  if exists('b:file')
    let file=b:file
  elseif exists('b:finfo') && ( type('b:finfo') == type({}) )
    let file = get(b:finfo,'path','')
  endif

  if !strlen(file) | return 0 | endif

  let rdir = base#file#reldir(file,dir)
  if strlen(rdir)
    let is = 1
  endif

  return is

endfunction

" Usage:
"   call base#buf#open_split({ 
"     \ 'lines' : lines,
"     \ 'cmds_pre' : [],
"     \ })

function! base#buf#open_split (ref)
    let ref      = a:ref

    let lines    = get(ref,'lines',[])
    let text     = get(ref,'text','')
    let action   = get(ref,'action','split')

    let stl_add  = get(ref,'stl_add',[])

    let cmds_pre   = get(ref,'cmds_pre',[])
    let cmds_after = get(ref,'cmds_after',[])

    let Fc         = get(ref,'Fc','')
    let Fc_args    = get(ref,'Fc_args',[])

    if len(text)
      let textlines = split(text,"\n")
      call extend(lines, textlines)
    endif

    if !len(lines)
      return
    endif
    
    exe action . ' '
    enew
    setlocal buftype=nofile
    setlocal nobuflisted

    call base#buf#map_add({ 'q' : 'quit' })
    let str = escape('[q - quit]',' ')
    exe printf('setlocal statusline=%s',str)

    if len(stl_add)
      for stl in stl_add
        exe printf('setlocal statusline+=%s',escape(stl,' '))
      endfor
    endif

    "setlocal nomodifiable
    "
    for cmd in cmds_pre
      exe cmd
    endfor

    let lnum = line('.')
    if len(lines)
      for l in lines
        call append(lnum,l)
        let lnum+=1
      endfor
    endif

    call base#varset('last_split_lines',lines)

    if type(Fc) == type(function('call'))
      call call(Fc,Fc_args)
    endif

    for cmd in cmds_after
      exe cmd
    endfor
    resize 999

endfunction

function! base#buf#pathids_str ()
  let ids = base#buf#pathids()
  return join(ids,' ')

endfunction

function! base#buf#pathid_first ()
  if exists("b:pathid_first")
    return b:pathid_first
  endif
  let ids = base#buf#pathids()
  return get(ids,0,'')

endfunction

function! base#buf#pathids ()

  if !exists("b:file")
    call base#buf#start()
  endif

  let fi = 'home hm vim vrt'
  let fis = base#qw(fi)

  let ids = base#pathids(b:file)

  call filter(ids,"! base#inlist(v:val,fis)")

  return ids
endfunction

function! base#buf#map_add (mp, ... )
  let mp  = a:mp

  let ref = get(a:000,0,{})

  let map = get(ref,'map','nnoremap')

  for [ k, v ] in items(mp)
    exe printf('%s <buffer><silent> %s :%s<CR>', map, k, v)
  endfor

  if !exists("b:maps") | let b:maps = {} | endif

  if base#type(mp) == 'Dictionary'
    if exists('b:maps[map]')
      call extend(b:maps[map], mp)
    else
      let b:maps[map] = mp
    endif
  endif
endfunction

function! base#buf#maps ()

  "\  '\t'        : 'call ap#GoToFileLocation() | terminal'              ,

  let maps = {
        \ 'nnoremap' :
          \ {
          \  ';za'       : 'ZLAN add'              ,
          \  ';zv'       : 'ZLAN view'             ,
          \  ';fo'       : 'PJact file_open'       ,
          \  ';h'        : 'BufAct help'           ,
          \  '?'         : 'BufAct help'           ,
          \  ';l'        : 'ls!'                   ,
          \  ';ma'       : 'MM tgadd_all'          ,
          \  ';ms'       : 'MM snippets_reload_all'  ,
          \  ';sv'       : 'SnippetView ' . &ft    ,
          \  ';ts'       : 'BufAct tabs_to_spaces' ,
          \  ';tu'       : 'TgUpdate'              ,
          \  ';tf'       : 'TgUpdate thisfile'     ,
          \  ';tv'       : 'TgView _tagfiles_'     ,
          \  ';il'       : 'IDEPHP load_project'   ,
          \  ';nk'       : 'call base#buf#set#no_keymap()'   ,
          \  ';ic'       : 'call base#buf#set#ignorecase()'   ,
          \  ';c'        : 'call base#buf#set#no_ignorecase()'   ,
          \  ';sp'       : 'call base#buf#set#paste()'   ,
          \  ';np'       : 'call base#buf#set#nopaste()'   ,
          \  ';co'       : 'BaseAct copen'         ,
          \  ';cc'       : 'BaseAct cclose'        ,
          \  '<F1>'      : 'BaseAct make'          ,
          \  '<F3>'      : 'BaseAct copen'         ,
          \  '<F4>'      : 'BaseAct cclose'        ,
          \  '<F7>'      : 'GitSave'               ,
          \  '<F9>'      : 'TgUpdate'              ,
          \  '<F11>'     : 'MM tgadd_all'          ,
          \  '<F12>'     : 'TgView _tagfiles_'     ,
          \  '<S-S>'     : 'call base#buf#git_status()'   ,
          \  '<C-S>'     : 'call base#buf#save()'         ,
          \  '<C-A>'     : 'call base#buf#git_add()'      ,
          \  '<C-G>'     : 'call base#buf#save_git()'     ,
          \  '<leader>l' : 'call base#buf#lines_hi()' ,
          \  '.'         : 'vertical resize -3' ,
          \  ','         : 'vertical resize +3' ,
          \ }
        \ }

  let r = { 'maps' : maps }
  call base#buf#onload_process_ft(r)
  call base#buf#onload_process_ext(r)

  for [ map, mp ] in items(maps)
    call base#buf#map_add(mp,{ 'map' : map })
  endfor


endfunction

" Usage
"   call base#buf#onload()
"
" call tree: 
"   called by: 
"     base#init#au
"   calls:
"     base#buf#maps
"       base#buf#onload_process_ft
"       base#buf#onload_process_ext

function! base#buf#onload ()
  call base#buf#start()

  if !base#buf#is_file() | return | endif

  if !strlen(&stl)
    StatusLine simple
  endif

  let b:comps_BufAct = base#comps#bufact()

  call base#buf#maps()

  call base#var#update('buf_vars')

endfunction

function! base#buf#onload_process_ext (...)
  let ref  = get(a:000,0,{})

  if b:ext == 'tags'
    setf tags

  elseif b:ext == 'nsh'
    setf nsis

  endif
endfunction

if 0
  called by:
    base#buf#onload
endif

function! base#buf#onload_process_ft (...)
  let ref  = get(a:000,0,{})

  let maps = get(ref,'maps',{})

  let dict = base#qw#catpath('plg','base data txt vim_dict '.&ft. ' dict.txt' )
  if filereadable(dict)
    exe 'setlocal dict+='.dict
  endif

  if &ft == 'php'
    setlocal iskeyword+=\
    call extend(maps.nnoremap,{ ';gg' : 'BufAct tggen_phpctags' })

  elseif &ft == 'snippets'
    setlocal ts=2

  elseif &ft == 'vim'
    call extend(maps.nnoremap,{ ';ss' : 'BufAct source_script' })
    if b:basename == 'html.vim'
      TgAdd perl_html
    endif


  elseif &ft == 'idat'
    "BufAct update_var 
    "
  elseif &ft == 'make'
    call base#cdfile()
    let b:make_data = {}
    let opts_active = []

    if has('win32')
      let opts = base#qw('dmake gmake')
      for opt in opts
        if len(base#where(opt))
          call add(opts_active,opt)
          exe printf('setlocal makeprg=%s',opt)
        endif
      endfor
      call extend(b:make_data,{ 'opts_active' : opts_active })
    endif

  elseif &ft == 'help'

    setlocal iskeyword+=<,>
    setlocal iskeyword+=/
    setlocal iskeyword+=$
  endif
endfunction

function! base#buf#git_status ()
  call base#buf#start()

  call base#cd(b:dirname)

  let s:obj = {}
  function! s:obj.init (...) dict
    let this      = get(a:000,0,{})
    let data      = get(a:000,1,{})
    let out       = get(data,'out',[])
    call base#buf#open_split({ 'lines' : out })
  endfunction
  
  let Fc = s:obj.init

  let r = {
      \  'cmds' : [
        \ [ 'git st',[],[],Fc,'' ],
      \ ],
      \  }


  call asc#run_many(r)

endfunction

function! base#buf#git_add ()
  call base#buf#start()

  call base#cd(b:dirname)

  let s:obj = {}
  function! s:obj.init (...) dict
    let this      = get(a:000,0,{})
    let data      = get(a:000,1,{})
    let out       = get(data,'out',[])
    call base#rdw('OK: git add','DiffDelete')
    "call base#buf#open_split({ 'lines' : out })
  endfunction
  
  let Fc = s:obj.init

  let r = {
      \  'cmds' : [
        \ [ printf('git add %s', shellescape(b:file)),[],[],Fc,'' ],
      \ ],
      \  }

  call asc#run_many(r)

endfunction

function! base#buf#save_git ()
  call base#buf#start()

  call base#cd(b:dirname)

  let s:obj = {}
  function! s:obj.push (...) dict
    call base#rdw('Done: Buffer Git save')
  endfunction

  function! s:obj.pull (...) dict
    call base#rdw('Done: git pull')
  endfunction

  function! s:obj.cimu (...) dict
    call base#rdw('Done: git cimu')
  endfunction
  
  let r = {
      \  'cmds' : [
        \ [ 'git cimu',[],[],s:obj.cimu,'' ],
        \ [ 'git pull',[],[],s:obj.pull,'' ],
        \ [ 'git push',[],[],s:obj.push,'' ],
      \ ],
      \  }

  call asc#run_many(r)

endfunction

function! base#buf#save ()
  call base#buf#start()

  w
  call base#rdw('OK: Buffer saved')
  "call base#cd(b:dirname)

"  let cmd = 'git cimu'
  
  "let env = {}
  "function env.get(temp_file) dict
    "let code = self.return_code
  
    "if filereadable(a:temp_file)
      "let out = readfile(a:temp_file)
    "endif
  "endfunction
  
  "call asc#run({ 
    "\  'cmd' : execmd, 
    "\  'Fn'  : asc#tab_restore(env) 
    "\  })

endfunction

function! base#buf#onread ()
  call base#buf#start()

  if exists("b:scp_data")
    call base#scp#fetch({ 'scp_data' : b:scp_data })
    call base#scp#tags_set()
  endif

endfunction

function! base#buf#onwrite ()
  call base#buf#start()

  if exists("b:scp_data")
    call base#scp#send({ 'scp_data' : b:scp_data })
  endif

endfunction

function! base#buf#stat ()
  call base#buf#start()
  let st = base#file#stat(b:file)

  let lines = []
  for [k,v] in items(st)
    "call add(lines,)
  endfor

endfunction

function! base#buf#insert_snip ()
  call base#buf#start()

  let ft_old = exists('g:snippet_ft') ? g:snippet_ft : ''

  let g:snippet_ft = input('snippet ft:','','custom,snipMate#complete#snips_all')

  let snip = input('snippet:','','custom,snipMate#complete#snippetNames')

  call snipMate#SnippetInsert(snip)

  let g:snippet_ft = ft_old
endfunction


function! base#buf#au_write_post ()
  call base#buf#start()

  let ft = &ft
  if base#inlist( ft, base#qw('idat xml') )
    BufAct update_var 
  endif
  
endfunction

if 0

  call tree
    called by
      base#buf#start
    calls
      base#buf#start
endif

function! base#buf#is_plg ()
  call base#buf#start()

  let pall     = base#varget('plugins_all',[])
  
  for plg in pall
    let plgdir   = base#qw#catpath('plg',plg)
    
    let b:cr      = base#file#commonroot([ b:dirname, plgdir ] )
    let b:belongs = ( b:cr == plgdir )
    
    if b:belongs
       let b:plg=plg
       break
    endif
  endfor

endfunction


function! base#buf#db_info ()
  let info = []

  if exists("b:db_info")
    let db_info = b:db_info

    let dbfile  = get(db_info,'dbfile','')
    let table   = get(db_info,'table','')

    let record  = get(db_info,'record',{})
    let rowid   = get(record,'rowid','')

    let q = 'SELECT rowid,* FROM ' . table . ' WHERE saved_file = ?'  
    let p = [ b:file ]
    let [ rows_h, cols ] = pymy#sqlite#query({
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : p,
      \ })
    let record = get(rows_h,0,{})
    call extend(b:db_info,{ 'record' : record })

    call add(info,'DB INFO:')
    let y = base#dump#yaml(b:db_info)
    let y = base#map#add_tabs(y)
    call extend(info,y)
  endif
  call base#buf#open_split({ 'lines' : info })
endfunction

function! base#buf#is_file ()
  let isf = ( !strlen(bufname('%')) || &buftype == 'nofile') ? 0 : 1
  return isf

endfunction

function! base#buf#start ()
  if !base#buf#is_file() | return | endif

  if exists("b:base_buf_started") | return | endif

  let b:file     = expand('%:p')
  let b:basename = expand('%:p:t')
  let b:ext      = expand('%:p:e')
  let b:dirname  = expand('%:p:h')
  let b:bufnr    = bufnr('%')

  if ! len("&ft")
    setlocal ft=text
  endif

  let b:file_se  = shellescape(b:file)

  let msg = [ 'b:basename = ' . b:basename, 'b:bufnr = ' . b:bufnr ]
  let prf = { 'plugin' : 'base', 'func' : 'base#buf#start' }
  call base#log(msg,prf)

  let b:filetype = &ft
  
  if exists('b:finfo') | unlet b:finfo | endif

  let b:finfo   = base#getfileinfo()

  if exists('b:finfo') && type(b:finfo) == type({})
    let b:pathids  = get(b:finfo,'pathids',[])
  endif

  let b:base_buf_started = 1

  call base#buf#is_plg()
endfunction
"""end_f_base#buf#start

fun! base#buf#varlist()
  let vars = base#buf#vars()
  let varlist = sort(keys(vars))
  return varlist
endfun

"Usage:
" call base#buf#vars_buf()
" call base#buf#vars_buf(buf_num)
" call base#buf#vars_buf(buf_num, var_name)

fun! base#buf#vars_buf(...)
  let buf_num  = get(a:000,0,0)
  let var_name = get(a:000,1,'')
  let default  = get(a:000,2,'')

  let bv = base#varget('buf_vars',{})
  if buf_num
    let bvn = get(bv,buf_num,{})
    if strlen(var_name)
      let val = get(bvn,var_name,default)
      return val
    else
      return bvn
    endif
  else
    return bv
  endif

endfun

"call base#buf#vars_buf_set ( buf_num, var_name, var_value )

fun! base#buf#vars_buf_set(...)
  let buf_num  = get(a:000,0,0)
  let var_name = get(a:000,1,'')
  let var_value = get(a:000,2,'')

  let bv = base#varget('buf_vars',{})
  let bbv = get(bv,buf_num,{})

  call extend(bbv,{ var_name : var_value })

  call extend(bv,{ buf_num : bbv })
  call base#varset('buf_vars', bv)

endfun

fun! base#buf#var(...)
  let varname = get(a:000,0,'')

  let vars  = base#buf#vars()
  let value = get(vars,varname,'')

  return value
endfun

fun! base#buf#vars()
  redir => bv
  silent let b:
  redir END 

  let bv_lines = split(bv,"\n")
  let vars = {}
  for line in bv_lines
    let var = matchstr(line, '^b:\zs\(\w\+\)\ze\s\+' )
    if strlen(var)
      let val = eval('b:' . var)
      call extend(vars,{ var : val })
    endif
  endfor

  return vars
endfun
