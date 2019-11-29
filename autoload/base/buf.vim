
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

function! base#buf#act(...)
  let start = get(a:000,0,0)
  let end   = get(a:000,1,getline('$'))
  let act   = get(a:000,2,'')

  if !strlen(act) 
    if exists("b:comps_BufAct")
      let comps = b:comps_BufAct
      let act = base#getfromchoosedialog({ 
        \ 'list'        : comps,
        \ 'startopt'    : get(comps,0),
        \ 'header'      : "Available actions for BufAct are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose BufAct action by number: ",
        \ })
    endif
  endif

  if !strlen(&ft) 
    echoerr 'No filetype!'
    return 
  endif

  call base#varset('bufact_start',start)
  call base#varset('bufact_end',end)

  let acts = exists('b:comps_BufAct') ? b:comps_BufAct : []

  "if !base#inlist(act,acts)
    "return
  "endif

  let ft   = &ft
  if base#inlist(ft,base#qw('html xhtml'))
    let ft = 'html'
  endif
  let subs = []
 " if base#inlist(ft,base#qw('php html'))
    "for ff in base#qw('html php')
      "let acts_ff = acts
      "call extend(acts_ff,base#varget('comps_BufAct_'.ff,[]))
      "if base#inlist(act,acts_ff)
        "let sub  = 'base#bufact#'.ff.'#'.act
        "call add(subs,sub)
      "endif
    "endfor
   "else
  "endif
  "
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

"base#buf#open_split({ 'lines' : lines })

function! base#buf#open_split (ref)
    let ref      = a:ref

    let lines  = get(ref,'lines',[])
    let text   = get(ref,'text','')
    let action = get(ref,'action','split')

    let cmds_pre = get(ref,'cmds_pre',[])

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

    nnoremap <buffer><silent> q :quit<CR>

    let str = escape('[q - quit]',' ')
    exe 'setlocal statusline+='.str

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

" Usage
"   call base#buf#onload()
"
" call tree: 
"   called by: 
"     base#init#au

function! base#buf#onload ()
  call base#buf#start()

  if !base#buf#is_file() | return | endif

  "StatusLine simple
  "
  exe 'nnoremap <buffer><silent> ;sv :SnippetView '.&ft.'<CR>'
  exe 'nnoremap <buffer><silent> ;fo :PJact file_open<CR>'
  exe 'nnoremap <buffer><silent> ;ts :BufAct tabs_to_spaces<CR>'

  let b:comps_BufAct = base#comps#bufact()

  if b:ext == 'tags'
    setf tags

  elseif b:ext == 'nsh'
    setf nsis

  elseif &ft == 'vim'
    exe 'nnoremap <buffer><silent> ;ss :BufAct source_script<CR>'
    if b:basename == 'html.vim'
      TgAdd perl_html
    endif

  elseif &ft == 'idat'
    "BufAct update_var 

  elseif &ft == 'help'

    setlocal iskeyword+=<,>
    setlocal iskeyword+=/
    setlocal iskeyword+=$
  endif

  call base#var#update('buf_vars')

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

  if b:filetype == 'idat'
    BufAct update_var 
  endif
  
endfunction

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
