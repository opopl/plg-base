
"function! base#plg#loadfun(...)
"endf


function! base#plg#loaded (...)
  let plg=a:1
  if !base#varexists('plugins')
    return 0
  endif
  let plugins = base#varget('plugins',[])

  if !base#inlist(plg,plugins)
    return 0
  endif

  return 1  
endfunction

function! base#plg#runtime (...)
  let plg = get(a:000,0,'')

  if !base#plg#exists(plg)
    exe 'runtime! plugin/*.vim'
  else
    let plgdir = base#qw#catpath('plg',plg)
    let after  = base#file#catfile([plgdir, 'after' ])
    
    let dirs = [
      \ base#file#catfile([plgdir, 'plugin' ]),
      \ base#file#catfile([after, 'plugin' ]),
      \ ] 
    let exts=base#qw('vim')

    call base#rtp#add_plugin(plg)
    let vf = base#find({
      \ "dirs" : dirs,
      \ "exts" : exts,
      \ })
    for f in vf
      silent exe 'so '.f
    endfor

  endif
endf  

function! base#plg#datpaths (...)
    let ref = get(a:000,0,{})

    let plg  = get(ref,'plg','')
    let type = get(ref,'type','list')

    let dbfile = base#dbfile()

    let q = 'SELECT keyfull, datfile FROM datfiles WHERE plugin = ? AND type = ?'
    let p = [ plg, type ]

    let [ rows_h, cols ] = pymy#sqlite#query({
      \ 'dbfile' : dbfile,
      \ 'p'      : p,
      \ 'q'      : q,
      \ })
    let datpaths = {}
    for rh in rows_h
      let k = get(rh,'keyfull','')
      let v = get(rh,'datfile','')
      call extend(datpaths,{ k: v})
    endfor
    return datpaths
  
endfunction

""" call base#plg#loadvars (plg)
""" call base#plg#loadvars (plg,{ 'opts_readarr' : { ... } })
""" call base#plg#loadvars (plg,{ 'opts_readdict' : { ... } })

function! base#plg#loadvars (...)

  if ! a:0 | return | endif

  let plg = get(a:000,0,'')
  let ref = get(a:000,1,{})

  call base#plg#loadvars_dat(plg, ref )
  call base#plg#loadvars_xml(plg, ref )

  call base#rdw(printf('OK: base#plg#loadvars (plugin = %s)',plg))
endfunction

function! base#plg#loadvars_xml (...)
  if ! a:0 | return | endif

  let plg = get(a:000,0,'')
  let ref = get(a:000,1,{})

  let prf = { 
    \ 'func'   : 'base#plg#loadvars_xml',
    \ 'plugin' : 'base'
    \ }

  call base#log([
    \ 'plg => ' . plg,
    \ ],prf )

  let dir = base#qw#catpath(printf('plg %s data xml',plg))

  let xml_files = base#find({ 
    \ "dirs"        : [dir],
    \ "exts"        : 'xml',
    \ "relpath"     : 1,
    \ "subdirs"     : 1,
    \ "fnamemodify" : ':p',
    \ })

python3 << eof
import vim
from xml.etree import ElementTree
from xml.etree.ElementTree import (
  tostring
)

xml_files = vim.eval('xml_files')
plg       = vim.eval('plg')

vars = {}

for xml_file in xml_files:
  with open(xml_file, 'rt') as f:
    tree = ElementTree.parse(f)
    for var_node in tree.findall('.//var'):
      v_name = var_node.attrib.get('name')
      if v_name != 'base' : 
        v_name = plg + '_' + v_name
      v_type      = var_node.attrib.get('type')
      v_entry_tag = var_node.attrib.get('entry_tag')
      if v_type == 'dict' :
        var = {}
        for entry in tree.findall( './/' + v_entry_tag ):
          key   = entry.attrib.get('key')
          value = entry.attrib.get('value')
          if value is None:
            value = entry.text
          print(value)
          value_split = map(lambda x: x.strip(), value.split("\n") )
          value       = "\n".join(value_split)
          var.update({ key : value })
      if var is not None:
        vars.update({ v_name : var })
eof
  let vars = py3eval('vars')
  for [ k, v ] in items(vars)
    call base#varset(k,v)
  endfor
endfunction

function! base#plg#loadvars_dat (...)

  if a:0
    let plg = get(a:000,0,'')
    let ref = get(a:000,1,{})
  else
    return
  endif

  let dbfile = base#dbfile()

  let prf = { 'func' : 'base#plg#loadvars_dat', 'plugin' : 'base' }
  call base#log([
    \ 'plg => ' . plg,
    \ ],prf )

  let opts_readarr  = get(ref,'opts_readarr',{})
  let opts_readdict = get(ref,'opts_readdict',{})

  let dattypes = base#qw('list listlines dict')

  for type in dattypes
  
    let datpaths = base#plg#datpaths({ 'plg' : plg, 'type' : type })
  
    for [ keyfull, datpath ] in items(datpaths)
      if !filereadable(datpath)
        call base#warn({ 'text' : 'NOT exist: ' . datpath, 'prefix' : ''})
        continue
      endif

      let vname = keyfull

      if type == 'list'
        let vv = base#readarr(datpath,opts_readarr)

      elseif type == 'listlines'
        call extend(opts_readarr,{ 'splitlines' : 0 })
        let vv = base#readarr(datpath,opts_readarr)

      else
        let rf = { 'file' : datpath }
        call extend(rf,opts_readdict)
        let vv = base#readdict(rf)

      endif
  
      call base#varset(vname,vv)
      if exists("vv") | unlet vv | endif 
    endfor
  endfor

  let vars = base#varget(plg.'_vars',{})
  if type(vars) == type({})
    for [k,v] in items(vars)
        call base#varset(plg.'_'.k,v)
    endfor
  endif

endfunction

function! base#plg#opendat (...)
    let plg = get(a:000,0,'')

    let type = input('Type:','list','custom,base#complete#dattypes')

    let dir = base#qw#catpath('plg',plg . ' data ' . type)

    let files = base#find({ 
        \ "dirs"    : [ dir ],
        \ "exts"    : ['i.dat'],
        \ "relpath" : 1,
        \ "cwd"     : 0 })

    let df=base#getfromchoosedialog({ 
        \ 'list'        : files,
        \ 'startopt'    : get(files,0,''),
        \ 'header'      : "Available dat files are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose dat files by number: ",
        \ })
    let df = base#file#catfile([ dir, df ])

    call base#fileopen({ 
      \ "files"  : [ df ],
      \ 'action' : 'split'
      \ })

    call base#tg#add('plg_'.plg)
    call base#stl#set('plg')
  
endfunction



function! base#plg#name()
  if &buftype == 'nofile'
    return
  endif

  let relpath = base#plg#relpath()

  let sp = base#file#ossplit(relpath)
  let name = sp[0]
  
  return name
endf  

function! base#plg#relpath()

  let plg = base#path('plg')
  let relpath = base#file#removeroot(expand('%:p'),plg)

  return relpath

endf  

function! base#plg#category()

endf  

function! base#plg#help(...)
    let aa  = a:000
    let plg = get(aa,0,'')

    if !len(plg)
      let plg=input('Plugin:','projs','custom,base#complete#plg')
      if !len(plg) | return | endif
    endif

    let sub = plg.'#help'
    if exists("*".sub)
        exe 'call '.sub.'()'
    else
        return
    endif

endf  

function! base#plg#grep(...)
  let plg = get(a:000,0,'')

  while !strlen(plg)
    let plg = input('Plugin name:','base','custom,base#complete#plg')
  endw

  let plgdir = base#catpath('plg',plg)

  let pat = ''

  while !strlen(pat)
    let pat = input('GREP pattern:','','custom,base#complete#grep_history')
    call base#va#add('grep_history',pat)
  endw

  let grepopt     = base#grepopt()

  call base#grep({ 
    \ "pat"     : pat      ,
    \ "files"   : [plgdir] ,
    \ "opt"     : grepopt  ,
    \ })

endfunction

function! base#plg#dir(plg)

  let plg    = a:plg
  let plgdir = base#catpath('plg',plg)
  
  return plgdir

endfunction

"call base#plg#act(plg,act)
"call base#plg#act('base',act)
"call base#plg#act('_all_',act)

function! base#plg#act(...)
  let aa  = a:000

  let plg = get(aa,0,'')
  let act = get(aa,1,'')

  if !len(plg)
    let plg = input('Plugin:','','custom,ap#complete#plg')
    if !len(plg) | redraw! | return | endif
  endif

  if plg == '_all_'
    call base#varset('PlgAct_mode','all')

    let plgs = base#varget('plugins',[])
    for plg in plgs
      call base#plg#act(plg,act)
    endfor

    call base#varset('PlgAct_mode','single')
    return
  endif


  if !strlen(act)
    let act = input('Action:','','custom,ap#complete#plgact')
  endif

  if act == 'loadvars'
    call base#plg#loadvars(plg)
  elseif act == 'list_ftplugin_vim'
    call base#plg#list_ftplugin_vim(plg)
  endif

endfunction

function! base#plg#view(...)
  let aa  = a:000
  let plg = get(aa,0,'')
  if !len(plg)
    let plg=input('Plugin:','','custom,ap#complete#plg')
    if !len(plg) | redraw! | return | endif
  endif

  let ddir = [ $VIMRUNTIME, 'plg', plg  ]
  
  let rootdir  = base#file#catfile(ddir)

  let dirtype = input('Directory type:','autoload','custom,ap#complete#plgdirtypes')
  let dirs = {
      \ 'root' : rootdir,
      \ 'autoload' : base#file#catfile([ rootdir, 'autoload']),
      \ 'doc'      : base#file#catfile([ rootdir, 'doc']),
      \ 'data'     : base#file#catfile([ rootdir, 'data']),
      \ 'plugin'   : base#file#catfile([ rootdir, 'plugin']),
      \ 'ftplugin' : base#file#catfile([ rootdir, 'ftplugin']),
      \ }
  let dir = get(dirs,dirtype,'root')

  if ! isdirectory(dir)
    call ap#warn('Plugin directory does not exist: ' . dir )
    return 0
  endif
  "let files = ap#find({ 'dirs' : dir, 'ext' : 'vim:dat'} )
  "
  let extstr = input('File Extensions:','vim dat','custom,ap#complete#plgexts') 

  let files = base#find({ 
    \ 'dirs' : [ dir ]            ,
    \ 'exts' : base#qw(extstr)    ,
    \ 'subdirs' : 1               ,
    \ })

  echohl Title
  echo '-----------------------'
  echo "Available plugin's files are:"
  echo '-----------------------'
  echohl MoreMsg
  let i = 0 
  for file in files
    echo '(' . i . ') ' . file
    let i += 1
  endfor
  echo '-----------------------'
  echohl None
  let index = input('Choose file index:','')

  exe 'tabnew ' . files[index]
  StatusLine plg
  call base#tg#set('plg_'.plg)

endf

function! base#plg#exists(...)
  let plg = get(a:000,0,'')
  let plga = base#varget('plugins_all',[])

  return base#inlist(plg,plga)

endfunction

function! base#plg#new(...)
  if a:0
    let plg = a:1
  else
    let plg = input('New plugin name:','','custom,ap#complete#plg')
  endif

  let dirs = []
  let files = []
  let plgdir = base#catpath('plg',plg)

  call add(dirs,plgdir)

  let rdirs=[]
  call extend(rdirs, base#qw('ftplugin plugin autoload') )
  for rd in rdirs
    call add(dirs,base#file#catfile([ plgdir, rd ]))
  endfor

  let rfiles = [
      \ 'autoload ' . plg . '.vim'  ,
      \ 'plugin ' . plg . '.vim'  ,
      \ ]
  call map(rfiles,'base#file#catfile([ split(v:val," ") ])')

  echo 'Will create relative dirs: '
  echo '  ' . join(rdirs,' ')

  for dir in dirs
    echo "\n".'Want to create directory:'
    echo ' ' . dir
    let c = input('Create directory? (0/1) :',1)

    if c
      call base#mkdir(dir)
    endif
  endfor

  echo "\n".'Will create relative files: '
  echo '  ' . join(rfiles,' ')

  call extend(files,map(rfiles,'base#file#catfile([ plgdir, v:val ])'))

  for file in files
    call base#plg#newfile(plg,file)
  endfor

endfunction

function! base#plg#relfile(plg,file)
  let plgdir  = base#catpath('plg',a:plg)
  let relfile = base#file#removeroot(a:file,plgdir)

  return relfile

endfunction


function! base#plg#newfile(plg,file)

  let plg  = a:plg
  let file = a:file

  let rw = 0
  if filereadable(file)
    echo 'File already exists: '
    echo ' ' . file
    let rw=input('Overwrite? (1/0): ',rw)
  endif

  if !rw | return | endif

  let rfile = base#plg#relfile(plg,file)
  let front = base#file#front(rfile)

  let lines = [ '"""' . plg . '_' . front ]
  if front == 'autoload'
    call add(lines,' ')
    call add(lines,'function! ' . plg . '# ()')
    call add(lines,' ')
    call add(lines,'endf')
    call add(lines,' ')
  elseif front == 'ftplugin'
    call add(lines,' ')
  elseif front == 'plugin'
    call add(lines,' ')
  endif

  echo 'Writing to file: '
  echo '  ' . file

  call writefile(lines,file)

endfunction

"base#plg#load(plg)

function! base#plg#rtp_s(plg)

  let plg = base#catpath('plg', a:plg )

  let dirs=[ plg, base#file#catfile([ plg , 'after' ]) ]

  let rtp = []
  for dir in dirs 
    if isdirectory(dir)
      call add(rtp,dir)
    endif
  endfor

  let rtp   = base#uniq(rtp)
  let rtp_s = join(rtp,",")

  return rtp_s

endf

function! base#plg#cd(plg)

  let dir = base#catpath('plg',a:plg)

  if ! isdirectory(dir)
    call base#warn({ 'text' : 'No directory for plugin ' . a:plg })
    return 0
  endif

  call base#cd(dir)
  call base#tg#add('plg_'.a:plg)

  return 1

endf

