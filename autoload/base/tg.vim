
"  base#tg#set (id)
"  base#tg#set ()
"

function! base#tg#set (...)
  if a:0 | let tgid = a:1 | endif

  let ref = {}
  if a:0 > 1 | let ref = a:2 | endif

  let tfile = base#tg#tfile(tgid)
  let tfile = get(ref,'tfile',tfile)

  if get(ref,'update_ifabsent',1)
    if !filereadable(tfile)
      call base#tg#update(tgid)
    endif
  endif

  let tfile = escape(tfile,' \')
  exe 'setlocal tags=' . tfile
  let b:tgids = [ tgid ]
  
endfunction

function! base#tg#add (...)
  if a:0 | let tgid = a:1 | endif

  let ref = {}
  if a:0 > 1 | let ref = a:2 | endif

  let tfile = base#tg#tfile(tgid)
  let tfile = get(ref, 'tfile', tfile)

  let tfile = escape(tfile,' \')
  exe 'setlocal tags+=' . tfile
  let tgs = base#tg#ids() 
  call add(tgs,tgid)

  let tgs     = base#uniq(tgs)
  let b:tgids = tgs

endf

function! base#tg#go (...)
  let tgs = get(a:000,0,'')
  let ref = get(a:000,1,{})

  let tg=''
  if base#type(tgs) == 'String'
    let tg = tgs
    
  elseif base#type(tgs) == 'List'
    for tg in tgs
      call base#tg#go(tg,ref)
    endfor
    return
  endif

  let after  = get(ref,'after',[])
  let before = get(ref,'before',[])

  for cmd in before
    try
      exe cmd
    catch 
      echo v:exception
    endtry
  endfor

  try
    silent exe 'tag '. tg
  catch 
    echo v:exception
  endtry

  for cmd in after
    try
      exe cmd
    endtry
  endfor

    "catch /^Vim\%((\a\+)\)\=:E684

endfunction




function! base#tg#ids (...)
  if exists("b:tgids")
    let tgids=b:tgids
  else
    let tgids=[]
  endif

  return tgids

endf

function! base#tg#ids_comma (...)
  let tgids = base#tg#ids()

  if ( (type(tgids) == type([])) && len(tgids) )
    return join(tgids,',')
  endif
  return ''

endf


function! base#tg#tfile (...)
  if a:0 | let tgid = a:1 | endif

  let tdir = base#path('tagdir')

  call base#mkdir(tdir)

"""_tfile_thisfile
  if tgid == 'thisfile'
    let finfo    = base#getfileinfo()

    let dirname  = get(finfo,'dirname','')
    let basename = get(finfo,'filename','')

    let tfile    = base#file#catfile([ dirname, basename . '.tags' ])

  elseif tgid == 'ty_perl_inc'
    let tfile = base#qw#catpath('home','tygs perl_inc.tygs')

  elseif tgid == '_this_tagfile_'
    let tfile = expand('%:p')

"""_tfile_projs_this
  elseif tgid == 'projs_this'
    let proj  = projs#proj#name()
    let tfile = projs#path([ proj . '.tags' ])

"""_tfile_idephp_help
  elseif tgid == 'idephp_help'
    let tfile = base#qw#catpath('plg','idephp help tags')

  elseif tgid == 'help_perlmy'
    let tfile = base#qw#catpath('plg','perlmy doc tags')

  elseif tgid == 'help_python'
    let tfile = base#qw#catpath('plg','pymy doc tags')

  elseif tgid == 'help_html'
    let tfile = base#qw#catpath('plg','idephp help html tags')

  elseif tgid == 'help_latex'
    let tfile = base#qw#catpath('plg','idephp help latex tags')

  elseif tgid == 'help_css'
    let tfile = base#qw#catpath('plg','idephp help css tags')

  elseif tgid == 'help_javascript'
    let tfile = base#qw#catpath('plg','idephp help javascript tags')

  elseif tgid == 'help_mysql'
    let tfile = base#qw#catpath('plg','idephp help mysql tags')

  elseif tgid == 'help_jquery'
    let tfile = base#qw#catpath('plg','idephp help javascript jquery tags')

  else
    let tfile = base#file#catfile([ tdir, tgid . '.tags' ])
  endif

  return tfile
endf

function! base#tg#update_w_files (...)
  let ref = get(a:000,0,{})

  let filelist = get(ref,'filelist',[])
  let tgid     = get(ref,'tgid','')

  if !len(filelist)
    return ''
  endif

  let home = base#path('home')
  let f = base#qw#catpath(printf('tmp_bat list_tgupdate_%s.txt',tgid))
  let f_u = base#file#win2unix(f)

  call base#file#write_lines({ 
    \ 'lines' : filelist,
    \ 'file'  : f, 
    \})

  return f_u
endf

function! base#tg#update_w_bat (...)
  let execmd = ''

  let ref   = get(a:000,0,{})

  let tgid       = get(ref,'tgid','')
  let tfile      = get(ref,'tfile','')
  let f_filelist = get(ref,'f_filelist','')

  let libs        = get(ref,'libs','')
  let files       = get(ref,'files','')

  let cmd = 'ctags -R -o "' . ap#file#win( tfile ) . '" ' . libs . ' ' . files

  call base#varset('last_ctags_cmd',cmd)

  if filereadable(f_filelist)
    let cmd .=   ' -L ' . f_filelist
  endif

  if has('win32')
    let batlines = []

    call add(batlines,' ')
    call add(batlines,'@echo off')
    call add(batlines,' ')
    call add(batlines,'set tagid=' . tgid )
    call add(batlines,'set tfile="' . tfile . '"')
    call add(batlines,' ')
    call add(batlines,'echo tagfile: %tfile%')
    call add(batlines,'echo tagid: %tagid%')
    call add(batlines,' ')
    call add(batlines,cmd)
    call add(batlines,' ')

    let home = base#path('home')
    let batfile = base#qw#catpath( printf('tmp_bat tgupdate_%s.bat',tgid) )
    call base#file#write_lines({ 
      \ 'lines' : batlines, 
      \ 'file'  : batfile, 
      \})
    let execmd = '"' . batfile .'"'
  endif

  return [ cmd, execmd ]

endf

"Call tree:
" Called by:
"   base#tg#update
"
function! base#tg#update_tygs (...)
  let ref = get(a:000, 0, {})

  let tgid = get(ref, 'tgid', '' )
  let dirs = get(ref, 'dirs', [] )
  let prompt = get(ref, 'prompt', 0 )

  let tfile = base#tg#tfile(tgid)

  let dbfile = base#qw#catpath('db', tgid . '.db')

  let redo        = 1
  let do_nyt_prof = 1
  let files_limit = 0

  let exe_perl    = 'perl'

  if prompt
    let msg_a = [
      \ " ",  
      \ "REDO flag - sets redo flag in Base::PerlFile, and does all", 
      \ "   calculations from the file system", 
      \ " ",  
      \ "redo (1/0): ", 
      \ ]
    let msg = join(msg_a,"\n")
  
    let redo = base#input_we(msg, redo, {})

    let do_nyt_prof = input('profiling with Devel::NYTProf ? (1/0): ', do_nyt_prof )

    let files_limit = str2nr( input('files limit (0 for no limit): ', files_limit ) )
  endif

  if do_nyt_prof
    let exe_perl .= ' -d:NYTProf'
  endif

  let ref = {
      \ 'dirs'     : dirs,
      \ 'tfile'    : tfile,
      \ 'tgid'     : tgid,
      \ 'dbfile'   : dbfile,
      \ 'redo'     : redo,
      \ 'exe_perl' : exe_perl,
      \ }

  if files_limit
      call extend(ref, { 'files_limit' : files_limit } )
  endif

  let ok = base#ty#make(ref)
  return ok
endf

function! base#tg#update_Fc (self,temp_file)
  let self      = a:self
  let temp_file = a:temp_file

  let code = self.return_code

  let tgid = self.tgid
  let cmd  = self.cmd
  let opts = self.opts

  let l:end = localtime()
  let l:el  = l:end - self.start
  let l:els = ' ' . l:el . ' secs'

  let Fc_done  = get(self, 'Fc_done', '')
  let Fc_fail  = get(self, 'Fc_fail', '')

  redraw!
  let ok = 0
  if code == 0
    let ok = 1

    let m = 'OK: TgUpdate ' . tgid . l:els
    let prf = { 'plugin' : 'base', 'func' : 'base#tg#update' }
    call base#log([m], prf)

   else
     let ok = 0
     let m = 'FAIL: TgUpdate ' . tgid  . l:els
     call base#warn({ 'text' : m, 'prefix' : '' })

     if type(Fc_fail) == type(function('call'))
       call call(Fc_fail,[])
     endif

   endif

   let okref = { 
       \ "cmd"  : cmd,
       \ "tgid" : tgid,
       \ "ok"   : ok,
       \ "add"  : get(opts, 'add', 0) }

   let ok = base#tg#ok(okref)
   if type(Fc_done) == type(function('call'))
     call call(Fc_done,[])
   endif
   
   return ok
endf


"call base#tg#update (tgid)
"call base#tg#update (tgid,{ ... })
"call base#tg#update ()

function! base#tg#update (...)
  let opts = get(a:000,1,{})

  if a:0 
    let tgid = a:1
  else
    let tgs = base#tg#ids()
    for tgid in tgs
      call base#tg#update(tgid,{ 'add' : 1 })
    endfor
    return
  endif

  let msg = printf('tgid => %s, opts => %s', tgid, base#dump(opts) )
  let msgs = [ msg ]
  let prf = { 
    \ 'plugin' : 'base', 
    \ 'func'   : 'base#tg#update' }
  call base#log(msgs, prf)

  let f_filelist = ''

  " use asynccommand plugin commands
  let async = get(opts,'async',1)

  " commands to be run on success ( when tags have been generated )
  let cmds_done    = get(opts,'cmds_done',[])

  " function to be run on success
  let Fc_done      = base#fun#new({ 'cmds' : cmds_done })
  let Fc_done      = get(opts,'Fc_done',Fc_done)

  " commands on failure
  let cmds_fail    = get(opts,'cmds_fail',[])

  " callback on failure
  let Fc_fail      = base#fun#new({ 'cmds' : cmds_fail })
  let Fc_fail      = get(opts,'Fc_fail',Fc_fail)

  let refsys = {}

  "" stored in the corresponding dat-file
  let tgs_all = base#varget('tagids',[])

  " tagfile full path
  let tfile = base#tg#tfile(tgid)

  let libs  = ''

  " list of files
  let files = ''

  " list of files (to be written to a file which will be processed by 
  "   ctags via -L option)
  let files_arr = []

  " file with the list of files
  let filelist = ''

  let libs_as = join(base#qw("C:/Perl/site/lib C:/Perl/lib" ),' ')
  let execmd = ''

  if tgid  == ''

"""tgupdate_idephp_help
  elseif tgid == 'idephp_help'
    call idephp#help#helptags({ 
      \ 'tfile' : tfile 
      \ })

    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok= base#tg#ok(okref)
    return

  elseif tgid == 'ty_perl_inc'
    let cnt = input('(TgUpdate ty_perl_inc) Continue with making TYGS? (1/0) : ',0)
    if !cnt | return | endif

    let execmd = 'ty --inc --tfile ' . tfile

  elseif tgid == 'ty_perl_htmltool'

    let dir  = base#path('htmltool')
    let lib  = base#file#catfile([ dir, 'lib' ])
    let dirs = [ lib ]

    call base#tg#update_tygs({ 
      \ 'tgid'   : tgid ,
      \ 'dirs'   : dirs ,
      \ 'prompt' : 1 ,
      \ })

    return

"""tgupdate_help_perlmy
  elseif tgid == 'help_perlmy'
    call perlmy#help#helptags()

    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok= base#tg#ok(okref)
    return

  elseif tgid == 'help_mysql'
    let hdir   = base#qw#catpath('plg', 'idephp help mysql')

    call base#vim#helptags({ 'dir' : hdir })

    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

  elseif tgid == 'help_jquery'
    let hdir   = base#qw#catpath('plg', 'idephp help javascript jquery')

    call base#vim#helptags({ 'dir' : hdir })

    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

  elseif tgid == 'help_javascript'
    let hdir   = base#qw#catpath('plg', 'idephp help javascript')

    call base#vim#helptags({ 'dir' : hdir })

    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

  elseif tgid == 'help_bootstrap'
    let hdir   = base#qw#catpath('plg', 'idephp help bootstrap')

    call base#vim#helptags({ 'dir' : hdir })
    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

  elseif tgid == 'help_html'
    let hdir   = base#qw#catpath('plg', 'idephp help html')

    call base#vim#helptags({ 'dir' : hdir })
    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

"""tgupdate_help_tex
  elseif tgid == 'help_latex'
    let hdir   = base#qw#catpath('plg', 'idephp help latex')

    call base#vim#helptags({ 'dir' : hdir })
    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

  elseif tgid == 'help_css'
    let hdir   = base#qw#catpath('plg', 'idephp help css')

    call base#vim#helptags({ 'dir' : hdir })
    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

"""tgupdate_help_python
  elseif tgid == 'help_python'
    call pymy#help#helptags()

    let okref = { 
      \ "tgid" : tgid,
      \ "ok"   : 1,
      \ "add"  : 0, 
      \ }

    let ok = base#tg#ok(okref)
    return

"""tgupdate_help_plg_perlmy
  elseif tgid == 'help_plg_perlmy'
 "   call idephp#help#helptags()

    "let okref = { 
      "\  "tgid" : tgid,
      "\  "ok"   : 1,
      "\  "add"  : 0, 
      "\  }

    "let ok= base#tg#ok(okref)
    return

"""tgupdate_src_vim
  elseif tgid == 'src_vim'
    let dir_src = base#qw#catpath('src_vim', 'src')
    let dirs    = []

    call add(dirs,dir_src)
    call add(dirs,base#path('include_win_sdk'))

    let files_arr = base#find({ 
      \ "dirs"    : dirs,
      \ "exts"    : base#qw('c h'),
      \ "relpath" : 0,
      \ })

    let files = join(files_arr,' ')

"""tgupdate_php_adminer_src
  elseif tgid == 'php_adminer_src'
    let f     = idephp#pj#files_tags('adminer_src')
    call map(f,'base#file#win2unix(v:val)')
    let files = join(f,' ')

    let filelist = base#qw#catpath('plg','idephp pj files_tags '.tgid.'.txt')

    call base#file#write_lines({ 
      \ 'lines' : f, 
      \ 'file'  : filelist, 
      \})

    let a=[]

    call extend(a,[ 'ctags','-R -o' ] )
    call extend(a,[ base#string#qq( ap#file#win( tfile ) ) ] )
    call extend(a,[ libs ])
    call extend(a,[ '-L',base#string#qq(filelist) ] )
    
    let cmd = join(a," ")

    echo "Calling ctags command for: " . tgid 

    let ok = base#sys(refsys)

    let okref = { 
        \ "cmd"  : cmd,
        \ "tgid" : tgid,
        \ "ok"   : ok,
        \ "add"  : get(opts,'add',0) }

    let ok = base#tg#ok(okref)
  
    return  ok


  elseif tgid == 'php_funcs'
    let dir   = base#qw#catpath('php_funcs','')
    let libs .= ' ' . dir

"""tgupdate_php_urltotxt
  elseif tgid == 'php_urltotxt'

    let dir   = base#path('urltotxt')
    let libs .= ' ' . dir

"""tgupdate_perl_htmltool
  elseif tgid == 'perl_htmltool'

    let dir   = base#file#catfile([ base#path('htmltool'), 'lib' ])
    let libs .= ' ' . dir

  elseif tgid == 'perl_guestbook'
    let dir   = base#file#catfile([ base#path('repos_git'), 'guestbook', 'lib' ])
    let libs .= ' ' . dir

  elseif tgid == 'perl_webgui'

    let dir   = 'c:\src\webgui-master\lib'
    let libs .= ' ' . dir

  elseif tgid == 'perl_inc_plg_browser'

    let dir   = base#file#catfile([ base#path('plg'), 'browser', 'perl' ])
    let libs .= ' ' . dir

  elseif tgid == 'perl_inc_plg_base'

    let dir   = base#file#catfile([ base#path('plg'), 'base', 'perl', 'lib' ])
    let libs .= ' ' . dir

  elseif tgid == 'perl_inc_plg_projs'

    let dir   = base#file#catfile([ base#path('plg'), 'projs', 'perl', 'lib' ])
    let libs .= ' ' . dir

  elseif tgid == 'perl_inc_plg_idephp'

    let dir   = base#file#catfile([ base#path('plg'), 'idephp', 'perl', 'lib' ])
    let libs .= ' ' . dir

"""tgupdate_perl_inc_select
  elseif tgid == 'perl_inc_select'
    let mods = base#varget('perlmy_mods_perl_inc_select',[])
    let locs = {}

    for mod in mods
      let cmd = 'pminst -l '.mod

      let ok  = base#sys({ "cmds" : [cmd]})
      let out = base#varget('sysout',[])

      call extend(locs,{ mod : out })
    endfor

    let json = base#json#encode(locs)

"""tgupdate_perl_inc
  elseif tgid == 'perl_inc'

    let a = base#envvar_a('perllib')
    let a = perlmy#perl#inc_a()
    "let libs=join( map ('ap#file#win(a:val)',a) )
    let libs = join(a,' ')

    let cnt = input('(TgUpdate perl_inc) Continue? 1/0: ',0)
    if !cnt
      return
    endif

    let async = input('Use async? 1/0: ',1)

"""tgupdate_x_php
  elseif tgid == 'x_php'
    let dir   = base#qw#catpath('x_php','')
    let libs = ' '
    let files = ' '

    let pj = idephp#pj#get()

    if pj != 'x_php'
      call idephp#pj#load('x_php')
    endif
    let files_arr = idephp#pj#files_load()

"""basetg_update_mkvimrc
  elseif tgid =~ 'mkvimrc'

    let dir = base#path('mkvimrc')
    let cwd = getcwd()

    let files_arr = base#find({ 
      \ "dirs"    : [ dir ],
      \ "exts"    : [ "vim"  ],
      \ "relpath" : 0,
      \ })

    let files = join(files_arr,' ')

"""basetg_update_plg
  elseif tgid == 'plg'
    let lines = []
    for tg in tgs_all
      if tg !~ '^plg_' | continue | endif

      let tf = base#tg#tfile(tg)
      if !filereadable(tf)
        call base#tg#update(tg)
      endif
      let l = readfile(tf)
      call extend(lines,l)
    endfor
    let lines = sort(lines)

    call writefile(lines,tfile)
    unlet lines

    if get(opts,'add',0)
      call base#tg#add(tgid)
    else
      call base#tg#set(tgid)
    endif

    return 1

"""basetg_update_plg_
  elseif tgid =~ '^plg_'
    "let pat = '^plg_\(\w\+\)$'
    let pat = '^plg_\(.\+\)$'
    let plg = substitute(tgid,pat,'\1','g')

    let plgdir   = base#catpath('plg',plg)
    let plgdir_u = base#file#win2unix(plgdir)

    let files_arr = base#find({ 
      \ "dirs" : [ plgdir ], 
      \ "exts" : [ "vim"  ], 
      \ })
    call map(files_arr,'base#file#win2unix(v:val)')
    call filter(files_arr,'filereadable(v:val)')

    let files = ' --language-force=vim ' . plgdir_u . '/*'
    let files = ''
    let path = base#qw#catpath('plg',plg)
    call base#cd(path)

"""tgupdate_projs_tex
  """ all tex files in current projs directory
  elseif tgid == 'projs_tex'
      if base#plg#loaded('projs')
        let root = projs#root()
    
         " let files_tex = base#find({ 
          "\  "dirs" : [ root ], 
          "\  "exts" : [ "tex"  ], 
          "\ })
        "let files = join(files_tex,' ')
        "echo files
        let files = base#file#catfile([ root,'*.tex' ])
      endif

"""tgupdate_projs_this
  elseif tgid == 'projs_this'
    if base#plg#loaded('projs')
        let proj  = projs#proj#name()
        let exts  = base#qw('tex vim bib')
    
        let files = proj . '.*.tex' . ' ' . proj . '.tex'
    
        let tfile = projs#path([ proj . '.tags' ])
    
        call projs#rootcd()
    endif

"""tgupdate_dir_this
  elseif tgid == 'dir_this'
     let dir = expand('%:p:h')
     let files_a = base#find({ 
        \ 'dirs' : [dir] 
        \ })
     let files = join(files_a,' ')

  elseif tgid == 'perlmod'
    let id = tgid

    call base#CD(id)

    let libs=join( [ 
      \ ap#file#win( base#catpath(id,'lib') ), 
      \ ] ," ")

    "let libs.=' ' . libs_as

"""thisfile
"""tgupdate_thisfile
  elseif tgid == 'thisfile'
    let files.= ' ' . expand('%:p')
  else 
    call base#warn({"text" : "unknown tagid!"})
    return 0
  endif

"""tgupdate_cmd_ctags

  let r_files = {
    \ 'filelist' : files_arr,
    \ 'tgid'     : tgid,
    \ }

  let f_filelist = base#tg#update_w_files(r_files)

  let r_bat = {
      \ 'tgid'       : tgid,
      \ 'tfile'      : tfile,
      \ 'f_filelist' : f_filelist,
      \ 'files'      : files,
      \ 'libs'       : libs,
      \ }

  let cmd = ''
  if !strlen(execmd)
    let [ cmd, execmd ] = base#tg#update_w_bat(r_bat)
  endif

  echo "Calling ctags command for: " . tgid 

  let l:start = localtime()

  if async && ( exists(':AsyncCommand') == 2 )
    let ok = 1

    let env = { 
      \ 'tgid'  : tgid, 
      \ 'cmd'   : cmd, 
      \ 'start' : l:start,
      \ 'opts'  : opts,
      \ }
    if type(Fc_done) == type(function('call'))
      call extend(env,{ 'Fc_done' : Fc_done })
    endif
    if type(Fc_fail) == type(function('call'))
      call extend(env,{ 'Fc_fail' : Fc_fail })
    endif

    function env.get(temp_file) dict
      call base#tg#update_Fc(self,a:temp_file)
    endfunction
"""tgupdate_async
    
    call asc#run({ 
      \ 'cmd' : execmd, 
      \ 'Fn'  : asc#tab_restore(env) 
      \ })

    return
  else
    call extend(refsys,{ 'cmds' : [ execmd ] })
    let ok = base#sys(refsys)
  endif

  let okref = { 
      \ "cmd"  : cmd,
      \ "tgid" : tgid,
      \ "ok"   : ok,
      \ "add"  : get(opts,'add',0) }

  let ok = base#tg#ok(okref)

  return  ok
endfunction
"""endf_base_tg_update

function! base#tg#ok (...)
  let okref = {}
  if a:0 | let okref = a:1 | endif

  let ok   = get(okref,'ok','')
  let add  = get(okref,'add',0)

  let tgid  = get(okref,'tgid','')

  let tfile = base#tg#tfile(tgid)
  let tfile = get(okref, 'tfile', tfile)
  
  "elapsed time
  let l:els  = get(okref, 'els', '')

  if ok
    redraw!
    echohl MoreMsg
    let msg = "TAGS UPDATE OK: " .  tgid 
    if strlen(l:els)
      let msg .= ' ' . l:els
    endif
    echo msg 
    echohl None

    let h = { 
      \ "update_ifabsent" : 0,
      \ }

    if strlen(tfile)
      call extend(h, { 'tfile' : tfile })
    endif

    if add 
      call base#tg#add (tgid, h)
    else
      call base#tg#set (tgid, h)
    endif

  else
    redraw!
    echohl Error
    let msg = "CTAGS UPDATE FAIL: " .  tgid
    if strlen(l:els)
      let msg .= ' ' . l:els
    endif
    echo msg
    echohl None
  endif

  return ok
  
endfunction

function! base#tg#view (...)

  if a:0 
    let tgid = a:1
  else
    let tgs = base#tg#ids()
    for tgid in tgs
      call base#tg#view(tgid)
    endfor
    return
  endif

  if tgid == '_tagfiles_'
    call base#tags#view()
    return
  endif

  let tfile = base#tg#tfile(tgid)

  if !filereadable(tfile)
    call base#tg#update(tgid)
  endif

  call base#fileopen(tfile)

  let tfile=escape(tfile,' \')
  exe 'setlocal tags+='.tfile
  
endfunction
