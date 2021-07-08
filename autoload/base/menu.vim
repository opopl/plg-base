
function! base#menu#remove(...)

  if a:0
    let menuopt = a:1
 else
    let menuopt = base#getfromchoosedialog({ 
        \ 'list'        : base#varget('menus',[]),
        \ 'startopt'    : 'projs',
        \ 'header'      : "Available menu options are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose menu option by number: ",
        \ })
 endif

 if menuopt == 'projs'
    call projs#menus#remove()

 elseif menuopt == '_vim_'
    let mns = base#varget('menus_remove__vim_',[])

    for mn in mns
      try 
        exe 'aunmenu &' . mn 
      catch
        echo v:exception
      endtry
    endfor

 elseif menuopt == 'sqlite'
    try 
      exe 'aunmenu &SQLITE.&COMMANDS'
      exe 'aunmenu &SQLITE'
    catch
    endtry
  else
    let uc = toupper(menuopt)
    try 
      exe 'aunmenu &' . uc 
    catch
     endtry
 endif

endfunction

function! base#menu#clear (...)
  let pref = get(a:000,0,'')

  if !strlen(pref)
    let pref = base#menu#pref()
  else
    call base#menu#pref(pref)
  endif

  if !strlen(pref)
    return
  endif

  try
    exe 'aunmenu &' . toupper(pref)
  catch 
  endtry
endfunction

function! base#menu#pref (...)
  let pref = get(a:000,0,'')

  if !exists("s:pref")
    let s:pref = ''
  endif

  if strlen(pref)
    let s:pref = pref
  endif

  return s:pref
endfunction

function! base#menu#sep (...)
  let ref=get(a:000,0,{})

  if !exists("s:sep_count")
    let s:sep_count = 1
  endif

  let id   = get(ref,'id','')
  let pref = get(ref,'pref','')

  if !strlen(id)
    let id = s:sep_count
    let s:sep_count += 1
  endif

  if !strlen(pref)
    let pref = base#menu#pref()
  endif

  let pref_a = map(base#qw(pref),'"&" . toupper(v:val) . "."')

  let pref_m = join(pref_a,"")

  let name =  printf('%s-Sep-',pref_m)
  if len(id)
    let name = printf('%s-Sep%s-',pref_m,id)
  endif
  let sep = {
           \  'item'  : name,
           \  'cmd'   : ' ',
           \  }
  return sep
endfunction

" Purpose
"   add menu 
" Usage
"   call base#menu#add(menuopt)
"   call base#menu#add(menuopt,{})
"   call base#menu#add(menuopt,{ 'action' : 'add' })
"   call base#menu#add(menuopt,{ 'action' : 'reset' })

function! base#menu#add(...)

 let opts = { 'action' : 'add' }

 if a:0
    let menuopt = get(a:000,0,'')
    if a:0 >= 2 
      call extend(opts,a:2)
    endif
 else
    let menuopt = base#getfromchoosedialog({ 
        \ 'list'        : base#varget('menus',[]),
        \ 'startopt'    : 'projs',
        \ 'header'      : "Available menu options are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose menu option by number: ",
        \ })
 endif

  if opts.action == 'reset'

    let menus_rm = []
    
    call extend(menus_rm,base#varget('menus_remove',[]))
    
    call extend(menus_rm,
    \   base#mapsub(base#varget('menus_toolbar_remove_items',[]),
    \   '^','ToolBar.','g'))
    
    call extend(menus_rm,keys(base#varget('allmenus',{}) ))
    
    let menus_rm = base#uniq(menus_rm)
    
    for m in menus_rm
        try
          exe 'aunmenu ' . m 
        catch
        endtry
    endfor

    call base#varhash#extend('isloaded',{ 'menus' : [ menuopt ] })

  elseif opts.action == 'add'
    let menus = base#varhash#get('isloaded','menus',[])
    call add(menus,menuopt)
    call base#varhash#extend('isloaded',{ 'menus' : menus })
  endif

"""_menuopt
 let menusbefore = [ 'menus', 'omni', 'buffers' ]
 if ! base#inlist(menuopt,menusbefore)
   for opt in menusbefore
     call base#menu#add(opt)
   endfor
 endif

  call base#menu#clear(menuopt)

"""menuopt_projs
 if menuopt == 'projs'
    call projs#menus#set()

    MenuAdd latex

"""menuopt_ssh
 elseif menuopt == 'ssh'
    let ssh_cmds = base#varget('cmds_SSH',[])
    for cmd in ssh_cmds
      call base#menu#additem({
        \   'item'  : '&SSH.&' . cmd,
        \   'tab'   : cmd,
        \   'cmd'   : 'SSH ' . cmd,
        \   })
    
    endfor

"""menuopt_scp
 elseif menuopt == 'scp'
    let scp_cmds = base#varget('cmds_SCP',[])

    let items = []
    for cmd in scp_cmds
      call add(items,{
        \   'item'  : '&SCP.&' . cmd,
        \   'tab'   : cmd,
        \   'cmd'   : 'SCP ' . cmd,
        \   })
    endfor

    for item in items
      call base#menu#additem(item)
    endfor

"""menuopt_makefiles
 elseif menuopt == 'makefiles'

     let lev=15
     let makefiles=[]
     let makefiles=base#find({ 
                    \       'qw_dirids'  : 'projs',
                    \       'qw_exts'    : 'mk',
                    \    })
    
     call add(makefiles,base#catpath('projs','makefile'))

     call add(makefiles,base#qw#catpath('scripts','mk maketex.defs.mk'))
     call add(makefiles,base#qw#catpath('scripts','mk maketex.targets.mk'))
    
     for mf in makefiles
         let mfname = substitute(fnamemodify(mf,':p:t'),'\.','\\.','g')
         let mfdir  = fnamemodify(mf,':p:r')
            
         call base#menu#additem({
                        \   'item'  : '&MAKEFILES.&' . mfname,
                        \   'tab'       :   mfname,
                        \   'cmd'       :   'call base#fileopen("' . mf . '")',
                        \   'lev'       :   lev,
                        \   })
    
     endfor

"""menuopt_sqlite
 elseif menuopt == 'sqlite'
    let cmds = base#varget('opts_BaseAct',[])
    call filter(cmds,'len(matchlist(v:val,"^sqlite_"))')
    call map(cmds,'substitute(v:val,"^sqlite_","","g")')

    for cmd in cmds
         call base#menu#additem({
              \   'item'      : '&SQLITE.&COMMANDS.&' . cmd,
              \   'tab'       :  cmd,
              \   'cmd'       :  'BaseAct sqlite_'.cmd,
              \   })
    endfor


"""menuopt_dat
 elseif menuopt == 'dat'
   LFUN F_ViewDAT

   VarUpdate datfiles

   let datroots={
        \   'PERL' : [ 
                \   'hperl_targets',
                \   'perldoc2tex_topics',
                \   'perl_installed_modules',
                \   'perl_used_modules',
                \   'modules_all',
                \   ],
        \   }

   for [root,dats] in items(datroots)
     for dat in dats
       call base#menu#additem({
            \   'item'  : '&DAT.&' . root . '.&' . dat,
            \   'tab'   : dat,
            \   'cmd'   : 'call F_ViewDAT("' . dat . '")',
            \   })
     endfor
   endfor

"""menuopt_omni
 elseif menuopt == 'omni'

   for [id,menuitem] in items(base#varget('menus_omni',{}))
      call base#menu#additem(menuitem)
   endfor

"""menuopt_perl
 elseif menuopt == 'perl'
   LFUN Prl_module_sub_open

   call Prl_module_subs()

   if exists("g:moduleinfo.subnames")
       for sub in g:moduleinfo.subnames
         call base#menu#additem({
                \   'item'  :   '&PERL.&SUBS.&' . sub,
                \   'tab'   :   'sub',
                \   'cmd'   :   'call Prl_module_sub_open(' . "'" . sub . "'" ,
                \   })
       endfor
   endif

   let funcs=[
        \   'Prl_module_subs',
        \   'Prl_module_path',
        \   'Prl_module_pod',
        \   ]

   for fun in funcs
        call base#menu#additem({
            \   'item'  :   '&PERL.&VimFuncsEcho.&' . fun,
            \   'tab'   :   'sub',
            \   'cmd'   :   'echo ' . fun . '()',
            \   })
        call base#menu#additem({
            \   'item'  :   '&PERL.&VimFuncsCall.&' . fun,
            \   'tab'   :   'sub',
            \   'cmd'   :   'call ' . fun . '()',
            \   })
   endfor

"""menuopt_plaintex
 elseif menuopt == 'plaintex'
   let menus_add=[
      \ 'ToolBar.PlainTexRun',
      \ ]

   call base#menus#add(menus_add)

"""menuopt_tags
 elseif menuopt == 'tags'

  call base#menu#pref('tags')
  call base#menu#clear()

  let items = []
  let tags  = taglist("^")

  call add(items, base#menu#sep() )
  for tag in tags
    let file = get(tag,'file','')
    let name = get(tag,'name','')
  endfor

"""menuopt_base
" For 'base' plugin
 elseif menuopt == 'base'
    let items = []

    call add(items, base#menu#sep() )
    
    for topic in base#info#topics()
       call add(items,{
          \   'item'  : '&BASE.&INFO.&' . topic,
          \   'cmd'   : 'INFO ' . topic,
          \   }
          \ )
    endfor

    call add(items, base#menu#sep() )
    for cmd in  base#varget('base_init_cmds',[])
       call add(items,{
          \   'item'  : '&BASE.&BaseInit.&' . cmd,
          \   'cmd'   : 'BaseInit ' . cmd,
          \   }
          \ )
    endfor

    call add(items, base#menu#sep() )
    call add(items,{
          \   'item'  : '&BASE.&BaseLog.&BaseLog',
          \   'cmd'   : 'BaseLog',
          \   }
          \ )
    call add(items, base#menu#sep() )
    for cmd in sort(base#varget('baselog_cmds',[]))
       call add(items,{
          \   'item'  : '&BASE.&BaseLog.&' . cmd,
          \   'cmd'   : 'BaseLog ' . cmd,
          \   }
          \ )
    endfor
    call add(items, base#menu#sep() )
    let AZ = base#list#new('A','Z')
    for dat in base#datlist()
      let H = toupper(dat[0])
      let HH = toupper(dat[0:1])
      call add(items,{
          \   'item'  : printf('&BASE.&BaseDatView.&%s.&%s.&%s', H, HH, dat),
          \   'cmd'   : 'BaseDatView ' . dat,
          \   }
          \ )
    endfor

    call add(items, base#menu#sep() )

   for item in items
     call base#menu#additem(item)
   endfor

"""menuopt_bufact
 elseif menuopt == 'bufact'
    let items = []
    let comps = exists('b:comps_BufAct') ? b:comps_BufAct : []

    call add(items,base#menu#sep())
    call add(items,{
      \   'item'  : '&BUFACT.&reload\ this\ menu' ,
      \   'cmd'   : 'MenuAdd bufact',
      \   }
      \ )
    call add(items,base#menu#sep())

   for cmd in comps
     call add(items,{
      \   'item'  : '&BUFACT.' . cmd,
      \   'cmd'   : 'BufAct ' .  cmd,
      \   }
      \ )
   endfor

   for item in items
     call base#menu#additem(item)
   endfor

"""menuopt_buffers
 elseif menuopt == 'buffers'

  let cmd = 'aunmenu BUFFERS'
     try
        silent exe cmd
     catch
        let msg = [
          \ 'error: ' . cmd ,
          \ ]
        let prf = {
          \ 'loglevel' : 'warn',
          \ 'plugin'   : 'base',
          \ 'func'     : 'base#menu#add',
          \ 'v_exception'     : v:exception
          \ }
        call base#log(msg,prf)
        
     endtry

  let items = []

  call base#menu#pref('buffers')

  call add(items,base#menu#sep())
  call add(items,{
    \   'item'  : '&BUFFERS.reload',
    \   'cmd'   : 'MenuAdd buffers',
    \   })
  call add(items,base#menu#sep())
  call add(items,{
    \   'item'  : '&BUFFERS.BufAct',
    \   'cmd'   : 'MenuAdd bufact',
    \   })
  call add(items,base#menu#sep())

   let bref     = base#buffers#get()
   
   let bufs     = get(bref,'bufs',[])
   let bufnums  = get(bref,'bufnums',[])
   let buffiles = get(bref,'buffiles',[])

   let bufmenus={}

   for buf in bufs
     let path = get(buf,'fullname','')
     let path_unix = base#file#win2unix(path)

     let num  = get(buf,'num',0)

     let path = base#trim(path)

     let mn  = ''
     let tab = ''

     let basename = fnamemodify(path,':p:t')
     let dirname  = fnamemodify(path,':p:h')
     let ext      = fnamemodify(path,':p:e')

     let basename_escape = substitute(basename,'\.','\\.','g')
     let dirname_escape  = substitute(dirname,'\.','\\.','g')
    
     if ! strlen(ext) | continue | endif
    
     let list = []
     call extend(list, [ '('.num.')' ])
     call extend(list, [ basename_escape ])
     call extend(list, [ base#file#win2unix(dirname_escape) ])
    
     let str = base#text#pack_perl ('A10 A50 A*', list )
     let str = escape(str,' ')
     let mn = printf('&BUFFERS.&%s.&%s', ext, str)

     if len(mn)
        let menu={
           \   'item'  : join([num,mn],' '),
           \   'cmd'   : 'buffer ' . path_unix,
           \   'tab'   : tab,
           \   }

        call extend(bufmenus,{ mn : menu })
     endif

   endfor

   for mn in sort(keys(bufmenus))
     let menu = bufmenus[mn]
     call add(items,menu)
   endfor

   for item in items
     call base#menu#additem(item)
   endfor

"""menuopt_lts
"""menu_lts
 elseif menuopt == 'lts'
   

"""menuopt_menus
 elseif menuopt == 'menus'

   call base#menu#pref('menus')
   call base#menu#clear()

   let items = []
   call add(items,base#menu#sep())
   call add(items, {
            \ 'item' : '&MENUS.&reload',
            \ 'cmd'  : 'MenuAdd menus',
            \ } )
   call add(items,base#menu#sep())
   call add(items, {
            \ 'item' : '&MENUS.&BaseDatView\ menus',
            \ 'cmd'  : 'BaseDatView menus',
            \ } )
   call add(items,base#menu#sep())

   for mn in base#varget('menus',[])
      call add(items,{
            \ 'item' : '&MENUS.&ADD.&' . mn,
            \ 'cmd'  : 'MenuAdd ' . mn,
            \ })
      call add(items,{
            \ 'item' : '&MENUS.&RESET.&' . mn,
            \ 'cmd'  : 'MenuReset ' . mn,
            \ })
   endfor

   for item in items
      call base#menu#additem(item)
   endfor

"""menuopt_latex
 elseif menuopt == 'latex'

   let items = []
   
      for entry in base#varget('tex_insert_entries',[]) 
          call add(items, {
            \ 'item' : '&TEX.&INSERT.&' . entry,
            \ 'cmd'  : 'TEXINSERT ' . entry,
            \ })
      endfor

      let texinputs = base#find({
            \ 'qw_dirids'    : 'texinputs',
            \ 'qw_exts'      : 'tex',
            \ 'fnamemodify'  : ':p:t',
            \ })

      for id in texinputs

        let fname = substitute(id,'\.','\\.','g')
        let file  = base#catpath('texinputs',fname)

        call add(items, {
              \ 'item' : '&TEX.&TEXINPUTS.&' . fname,
              \ 'cmd'  : 'call base#fileopen(' . "'" . file . "'" . ')',
              \ })
      endfor

      call add(items, {
            \ 'item' : '&TEX.&RUN.&pdfTeX' ,
            \ 'cmd'  : 'PlainTexRun',
            \ })

      for item in items
        call base#menu#additem(item)
      endfor

 endif
 
endfunction

function! base#menu#additem (ref)

 let cmd  = 'anoremenu '
 let cmds = []

 let ref = {
        \ 'icon'    : '',
        \ 'item'    : '',
        \ 'cmd'     : '',
        \ 'fullcmd' : '',
        \ 'tab'     : '',
        \ 'tmenu'   : '',
        \ }

 call extend(ref,a:ref)

 if len(ref.icon)
   let iconfile = base#catpath('menuicons',ref.icon . '.png')
   if filereadable(iconfile)
      let cmd.='icon=' . iconfile . ' '
   else
      call base#warn({ 'text' : 'icon file not readable:' . iconfile })
   endif
 endif

 if ! len(ref.item)
   call base#warn({ 'text' : 'menu item not defined!' })
   return
 else
   let cmd.=ref.item . ' '
 endif

 if ref.tab
   let cmd.='<Tab>' . ref.tab . ' '
 endif

 if ! len(ref.cmd)
   if ! len(ref.fullcmd)
     call base#warn('menu command not defined!')
     return
   else
     let cmd = ref.fullcmd
   endif
 else
   let cmd.=':' . ref.cmd . '<CR>'
 endif
 call add(cmds,cmd)

 if ref.tmenu
    call add(cmds,'tmenu ' . ref.item . ' ' . ref.tmenu)
 endif

 for cmd in cmds
  try
    exe cmd
  catch 
    echo v:exception
    echo cmd
  endtry
 endfor

 let isloaded = base#varget('isloaded',{})
 let mni      = get(isloaded,'menuitems',[])

 call add(mni,ref.item)
 call extend(isloaded, { 'menuitems' : mni })

 call base#varset('isloaded',isloaded)

endfunction
 

 
function! base#menu#add_alphabet(ref)

 let ref=a:ref

 let lev=10

 for id in g:{ref.arr}
        let lett=toupper(matchstr(id,'^\zs\w\ze'))

      call base#menu#additem({
        \ 'item'  : '&' . ref.name . '.&' . lett . '.&' . id,
        \ 'cmd' : ref.cmd . ' ' . id,
        \ 'lev' : lev,
        \ })

      let lev+=10
 endfor

endfunction

