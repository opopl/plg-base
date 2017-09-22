"see LFUN in base/plugin/base_init.vim

fun! base#loadvimfunc(fun)
 
  let fun = a:fun

  let fun = substitute(fun,'\s*$','','g')
  let fun = substitute(fun,'^\s*','','g')

  let fundir = base#path('funs')
  let funfile= base#catpath('funs',fun . '.vim')

  if !exists("g:isloaded") | let g:isloaded={} | endif

  if !exists("g:isloaded.vim_funcs_user")
      let g:isloaded.vim_funcs_user=[]
  else
      if index(g:isloaded.vim_funcs_user,fun) >= 0
        "return
      endif
  endif

  try
    exe 'source ' . funfile
    if index(g:isloaded.vim_funcs_user,fun) < 0
      call add(g:isloaded.vim_funcs_user,fun)
    endif
  catch
  endtry
  
endfun

"C:\Users\op\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe
"
"fun! base#pdfview(file,opts)
"fun! base#pdfview(file)

fun! base#pdfview(...)
  let file = get(a:000,0,'')
  let opts = get(a:000,1,{})

  let viewer = base#f#path('evince')

  if filereadable(file)
     if get(opts,'cdfile',0)
        call base#cdfile(file)
     endif

     let ec= 'silent! !start '.viewer.' '.file
     exe ec
     redraw!
  endif
endfun

""base_loadvimcommand
fun! base#loadvimcom(com)

  let com = a:com

  let com = substitute(com,'\s*$','','g')
  let com = substitute(com,'^\s*','','g')

  let comdir  = base#path('coms')
  let comfile = base#catpath('coms',com . '.vim')

  if !exists("g:isloaded") | let g:isloaded={} | endif

  if !exists("g:isloaded.commands")
     let g:isloaded.commands=[]
  else
     if index(g:isloaded.commands,com) >= 0
        return
     endif
  endif

  try
     exe 'source ' . comfile
     call add(g:isloaded.commands,com)
  endtry
 
endfun


fun! base#augroups()

    let g = ''
    redir => {g}
    augroup
    redir END
    
    let groups = split(g,' ')
    return groups

endfun

"""base_viewvimfunc
fun! base#viewvimfunc(...)
  let fun=a:1

  let funfile = base#catpath('funs',fun . '.vim')

  if ! base#vimfuncexists(fun)
    call base#vimfuncnew(fun)
  endif

  call base#fileopen(funfile)

  let g:vimfun=fun

  call base#stl#set('vimfun')
endfun

"""base_viewvimcom
fun! base#viewvimcom(...)
  let com=a:1

  let comfile = base#catpath('coms',com . '.vim')

  "if ! base#vimcomexists(fun)
    "call base#vimcomnew(fun)
  "endif

  call base#fileopen(comfile)

  let g:vimcom=com

  call base#stl#set('vimcom')
endfun

"""base_vimfuncexists
fun! base#vimfuncexists(fun,...)

    let f = base#var('vim_funcs_user')

    if index(f,a:fun) >= 0
        return 1
    endif

    return 0
  
endf

"""base_subwarn
fun! base#subwarn(msg)

  if !base#opttrue('warn')
    return
  endif

  echohl WarningMsg

  if exists("g:SubNames") && type(g:SubNames) == type([])
    let prefix=get(g:SubNames,-1) . ': '
  else
    let prefix=''
  endif
  let msg=prefix . a:msg

  "redraw!
  echo msg

  echohl None

endf


"""base_vimfuncnew
fun! base#vimfuncnew(...)

    if a:0
        let fun=a:1
    else
        let fun=input('New vim function name:','')
    endif       

    let funfile=base#catpath('vimfun',fun . '.vim')

    call base#echotab("Will write to file:", funfile )

    if filereadable(funfile)
        call base#subwarn('Vim function file already exists')
        let rw=input('Overwrite? (y/n):','n')
        if rw == 'n'
            return
        endif
    endif

    let funtypes=[ 'usual', 'complete' ]
    let funtype=base#getfromchoosedialog({ 
        \ 'list'        : funtypes,
        \ 'startopt'    : 'usual',
        \ 'header'      : "Available vim function types are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose vim function type by number: ",
        \ })

    let contents=[]
    let begin=[]
    let end=[]

    call add(begin,' ')
    call add(begin,'function! ' . fun . '(...)')

    if funtype == 'usual'
        let contents =[' ']
    
        call add(begin,' RFUN SubNameStart ' . fun )
    
        call add(end,' RFUN SubNameEnd ' )

    elseif funtype == 'complete'
        let contents =[]

        let arrname=input('Complete arr name:','')

        call add(contents,'LFUN F_CustomComplete' )
        call add(contents,' ' )
        call add(contents,'return F_CustomComplete([ ' ."'". arrname  ."'". ' ])'  )
        call add(contents,' ' )

    endif

    call add(end,'endfunction')

    let lines=[]
    call extend(lines,begin)
    call extend(lines,contents)
    call extend(lines,end)

    call writefile(lines,funfile)

    redraw!
    echohl MoreMsg
    echo "Written new vim function: " . fun
    echohl None

endfun

"""base_runvimfunc
fun! base#runvimfunc(fun,...)
  let fun=a:fun

  if a:0
    let args="'" . join(a:000,"','") . "'" 
  else
    let args=''
  endif

  exe 'LFUN ' . fun
 
  if exists("*" . fun)
    let callexpr= 'call ' . fun . '(' . args . ')'
    exe callexpr
  endif
  
endfun

"""base_varcheckexist
fun! base#varcheckexist(ref)

 if base#type(a:ref) == 'String'
   let varname=a:ref
   
 elseif base#type(a:ref) == 'List'
   let vars=a:ref
   for varname in vars
     call base#varcheckexist(varname)
   endfor

   return
 endif

 let varname=substitute(varname,'^\(g:\)*','g:','g')

 if ! exists(varname)
     "call ap#varupdate(varname)
 endif
 
endfun

" string width
function! base#sw (s)
  let a=a:s
  let v = (exists('*strwidth')) ? strwidth(a) : len(a)
  return v
endfunction

fun! base#opttrue(opt)
  let opt=a:opt

  let opts=base#varget('opts',{})

  if has_key(opts,opt) 
    if get(opts,opt,0)
      let res=1
    else
      let res=0
    endif
  else
    let res=0
  endif

  return res

endf


"""base_uniq
fun! base#uniq(...)

 let ref=a:1
 let opts={     
        \   'var' : 'local', 
        \   'sort' : 0,
        \   }

 if a:0 >= 2 
   call extend(opts,a:2)
 endif

 let h={}

 if base#type(ref) == 'String'
    let opts.arrname = substitute(ref,'^[g:]*','g:','g')
    let opts.var     = 'global'

    exe 'let arr=' . opts.arrname

 elseif base#type(ref) == 'List'
    let arr=ref
 endif

 let res=[]

 for a in arr 
   if ! base#inlist(a,res)
     call add(res,a)
   endif
 endfor

 if opts.sort
   let res=sort(res)
 endif

 if opts.var == 'global' && exists("opts.arrname")
   exe 'let ' . opts.arrname . '=res'
 endif

 return res
endf

"""base_echotab
fun! base#echotab(head,msg)

    echo a:head
    echo "\t" . a:msg

endf

"""base_type
fun! base#type(var)

  let type=''
  let var=a:var

  if type(var) == type('')
    let type='String'
  elseif type(var) == type(1)
    let type='Number'
  elseif type(var) == type(1.1)
    let type='Float'
  elseif type(var) == type([])
    let type='List'
  elseif type(var) == type({})
    let type='Dictionary'
  endif

  return type

endf


function! base#cdfile(...)
  let file = get(a:000,0,expand('%:p'))
  let dir  = fnamemodify(file,':p:h')

  exe 'cd ' . dir
endf

function! base#cd(dir,...)
    let ref = {}
    if a:0 | let ref = a:1 | endif

    let ech = get(ref,'echo',1)

    if ech
        exe 'cd ' . a:dir
        echohl MoreMsg
        echo 'Changed to: ' . a:dir
        echohl None
    endif
endf

function! base#isdict(var)
  if type(a:var)==type({})
    return 1
  endif
  return 0
endf

function! base#islist(var)
  if type(a:var)==type([])
    return 1
  endif
  return 0
endf

function! base#CD(dirid,...)
    let ref = {}
    if a:0 | let ref = a:1 | endif

    let dir = base#path(a:dirid)
    if isdirectory(dir)
        call base#cd(dir,ref)
    else
        call base#warn({ "text" : "Is NOT a directory: " . dir })
    endif
endf

"call base#catpath(key,[a,b,c])

"""base_catpath
fun! base#catpath(key,...)
 
 if !exists("s:paths")
    call base#initpaths()
 endif

 let pc = []

 if has_key(s:paths,a:key)
    call add(pc,s:paths[a:key])
 elseif a:key == '~'
    call add(pc,'~')
 else
 endif

 if a:0
    for a in a:000
        if base#type(a) == 'List'
            call extend(pc,a)
        elseif base#type(a) == 'String'
            call add(pc,a)
        endif
    endfor
 endif
    
 let fpath=base#file#catfile(pc)

 return fpath

endf

fun! base#initfiles(...)
    call base#echoprefix('(base#initfiles)')

    let ref = {}
    if a:0 | let ref = a:1 | endif

    let anew = 0
    if ! exists("s:files") 
        let anew = 1 
    else
        if get(ref,'anew',0) 
            let anew = 1 
        endif
    endif
        
    if anew
        call base#echo({ 
            \   "text" : 'Settings "files" hash anew...',
            \   })
        let s:files={}
    endif

  let evince =  base#file#catfile([ 
      \ base#path('home'),
      \ '\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe' 
      \ ])

    if filereadable(evince)
        call base#f#set({  'evince' : evince })
    endif

  let exefiles={}
  for fileid in base#var('exefileids')
    let  ok = base#sys({ "cmds" : [ 'where '.fileid ], "skip_errors" : 1 })

    if ok
        let found =  base#var('sysout')
        let add={}
        for f in  found
            if filereadable(f)
                let add[f]=1
            endif
        endfor
        let k = keys(add)
        if len(k)
          call extend(exefiles,{ fileid : k } )
        endif
    endif

  endfor

  call base#varset('exefiles',exefiles)
  call base#f#set(exefiles)

  call base#echoprefixold()
endf

"""base_initpaths

"call base#initpaths()
"call base#initpaths({ "anew": 1 })

fun! base#initpaths(...)
    call base#echoprefix('(base#initpaths)')

    let ref = {}
    if a:0 | let ref = a:1 | endif
 
"""define_paths

    let anew = 0
    if ! exists("s:paths") 
        let anew = 1 
    else
        if get(ref,'anew',0) 
            let anew = 1 
        endif
    endif
        
    if anew
        call base#echo({ 
            \   "text" : 'Settings paths anew...' 
            \   })
        let s:paths={}
    endif

    let confdir   = base#envvar('CONFDIR')
    let vrt       = base#envvar('VIMRUNTIME')
    let hm        = base#envvar('hm')
    let mrc       = base#envvar('MYVIMRC')
    let projsdir  = base#envvar('PROJSDIR')
    let pf        = base#envvar('PROGRAMFILES')

    let home      = base#envvar('USERPROFILE')

		let pc = $COMPUTERNAME

    let evbin = home.'\AppData\Local\Apps\Evince-2.32.0.145\bin'
		if isdirectory(evbin)
      call base#pathset({  'evince_bin' : evbin })
		endif

    call base#pathset({ 
        \ 'home'    : home ,
        \ 'hm'      : hm ,
        \ 'pf'      : pf ,
        \ 'conf'    : confdir ,
        \ 'vrt'     : vrt,
        \ 'vim'     : base#envvar('VIM'),
        \ 'texdocs' : projsdir,
        \ 'p'       : base#envvar('TexPapersRoot'),
        \ 'phd_p'   : base#envvar('TexPapersRoot'),
        \   })

    let mkvimrc  = base#file#catfile([ base#path('conf'), 'mk', 'vimrc' ])
    let mkbashrc = base#file#catfile([ base#path('conf'), 'mk', 'bashrc' ])

    call base#pathset({
        \   'pdfout'      : base#envvar('PDFOUT'),
        \   'htmlout'     : base#envvar('HTMLOUT'),
        \   'jsdocs'      : base#envvar('JSDOCS'),
				\	})

    call base#pathset({
        \   'open_server'      : base#file#catfile([ 'C:','OpenServer' ]),
				\	})

    call base#pathset({
        \   'jq_course_local'  : base#file#catfile([ base#path('open_server'),'domains', 'jq-course.local' ]),
        \   'quote_service_local'  : base#file#catfile([ base#path('open_server'),'domains', 'quote-service.local' ]),
				\	})

    call base#pathset({
        \   'ap_local'  : base#file#catfile([ base#path('open_server'),'domains', 'ap.local' ]),
        \   'inews_local'  : base#file#catfile([ base#path('open_server'),'domains', 'inews.local' ]),
				\	})


    call base#pathset({
				\   'desktop'     : base#file#catfile([ hm, base#qw("Desktop") ]),
        \   'mkvimrc'     : mkvimrc,
        \   'mkbashrc'    : mkbashrc,
        \   'coms'        : base#file#catfile([ mkvimrc, '_coms_' ]) ,
        \   'funs'        : base#file#catfile([ mkvimrc, '_fun_' ]) ,
        \   'projs'       : projsdir,
        \   'perlmod'     : base#file#catfile([ hm, base#qw("repos git perlmod") ]),
        \   'perlscripts' : base#file#catfile([ hm, base#qw("scripts perl") ]),
        \   'scripts'     : base#file#catfile([ hm, base#qw("scripts") ]),
        \   'projs_my'    : base#file#catfile([ hm, base#qw("repos git projs_my") ]),
        \   'projs_da'    : base#file#catfile([ hm, base#qw("repos git projs_da") ]),
        \   })

        "\  'projs_da'    : base#file#catfile([ base#qw("Z: ap projs_da") ]),

    "" remove / from the end of the directory
    for k in keys(s:paths)
       let s:paths[k]=substitute(s:paths[k],'\/\s*$','','g')
    endfor


    if exists("g:dirs")
       call extend(s:paths,g:dirs)
    endif
    let g:dirs = s:paths

    let pathlist= sort(keys(s:paths))
    call base#varset('pathlist',pathlist)

		echo '--- base#initpaths ( paths initialization ) --- '
		echo 'Have set the value of g:dirs'
		echo 'Have set the value of base variable "pathlist" (check it via BaseVarEcho)'
		echo '--------------------------------------------------- '

    call base#echoprefixold()

endf
 
"""base_fileopen
fun! base#fileopen(ref)
 let files=[]

 let action = 'edit'
 let a      = base#varget('fileopen_action','')


 let opts={}

 if base#type(a:ref) == 'String'
   let files = [ a:ref ] 
   
 elseif base#type(a:ref) == 'List'
   let files = a:ref  
   
 elseif base#type(a:ref) == 'Dictionary'
   let files = a:ref.files
   let a     = get(a:ref,'action',a)

   call extend(opts,a:ref)
   
 endif

 if strlen(a) | let action = a | endif

 for file in files
  exe action . ' ' . file
  let exec=get(opts,'exec','')
  if len(exec)
    if type(exec) == type([])
      for e in exec
        exe e
      endfor
    elseif type(exec) == type('')
      exe exec
    endif
  endif
 endfor
 
endfun
 

"""base_inlist
fun! base#inlist(element,list)
 let r=( index(a:list,a:element) >= 0 ) ? 1 : 0

 return r 

endfun

function! base#getfromchoosedialog_nums (ref)
	let ref  = a:ref
	let opts = get(ref,'list',{})

	let defs = {
			\	'startopt' : 'usual',
			\	'header'   : '',
			\	'numcols'  : 1,
			\	'bottom'   : "",
			\	}

	let inref={}
	call extend(inref,defs)
	call extend(inref,ref)

	let opts_rev={}
	for [k,v] in items(opts)
		call extend(opts_rev,{v : k})
	endfor

	let optlist=[]
	let optkeys=sort(keys(opts))

	for k in optkeys
		call add(optlist,opts[k])
	endfor

	call extend(inref,{ 'list' : optlist })

  let opt = base#getfromchoosedialog(inref) 

	let optnum = get(opts_rev,opt,0)
	return optnum

endfun

"""base_getfromchoosedialog
function! base#getfromchoosedialog (opts)

  if base#type(a:opts) != 'Dictionary'
    call base#warn({ 
        \   "text" : "wrong type of input argument 'opts' - should be Dictionary"
        \   })

    return
  endif

  let numcols  = 1
  let header   = 'Option Choose Dialog'
  let bottom   = 'Choose an option: '
  let selected = 'Selected: '

  let startopt = get( a:opts,'startopt','' )

  let keystr= "list startopt numcols header bottom selected"
  for key in base#qw(keystr)
      if has_key(a:opts,key)
        exe 'let ' . key . '=a:opts.' . key
      endif
  endfor

  try 
      let liststr=join(list,"\n")
  catch
    call base#warn({ 
        \   "text" : "input list of options was not provided"
        \})
    return
  endtry
    
    let dialog = header . "\n"
    let dialog.= base#createprompt(liststr, numcols, "\n") . "\n"
    let dialog.= bottom . "\n"
    let opt    = base#choosefromprompt(dialog,liststr,"\n",startopt)
    
    echo selected . opt
    
    return opt
    
endfunction

function! base#qwsort (...)

 if a:0
   let str=a:1
 else
   let str=''
 endif

 let a = base#qw(str)
 let a = sort(a)
 return a

endfunction

function! base#qw (...)

 if a:0
   let str=a:1
 else
   let str=''
 endif
  
 let arr=split(str,' ')

 call filter(arr,'strlen(v:val) > 0 ')

 return arr

endf

"""base_createprompt
function! base#createprompt (promptList, cols, sep)

    let g:listSep  = a:sep
    let num_common = base#getlistcount(a:promptList)

    let i = 1
    let promptStr = ""

    while i <= num_common

        let j = 0
        while j < a:cols && i + j <= num_common
            let com = base#strntok(a:promptList, a:sep, i+j)
            let promptStr = promptStr.'('.(i+j).') '. 
                        \ com."\t".( strlen(com) < 4 ? "\t" : '' )

            let j = j + 1
        endwhile

        let promptStr = promptStr."\n"

        let i = i + a:cols
    endwhile

  return promptStr

endfunction 

"""base_getlistcount
fun! base#getlistcount( array )
 
    if a:array == "" | return 0 | endif
    let pos = 0
    let cnt = 0
    while pos != -1
        let pos = matchend( a:array, g:listSep, pos )
        let cnt = cnt + 1
    endwhile

 return cnt

endfunction


" F_Strntok: extract the n^th token from a list
" example: Strntok('1,23,3', ',', 2) = 23

"""base_strntok
fun! base#strntok(s, tok, n)

 let n   = a:n
 let s   = a:s
 let tok = a:tok

 return matchstr( s . tok[0], '\v(\zs([^'. tok .']*)\ze['. tok .']){'. n .'}')

endfun


"""base_choosefromprompt
fun! base#choosefromprompt(dialog, list, sep, ...)

    let inp = input(a:dialog)

    if a:0 
        let empty=a:1
    else
        let empty=a:list[0]
    endif

    if inp =~ '\d\+'
        let res=base#strntok(a:list, a:sep, inp)
    elseif inp == ''
        let res=empty
    else
        let res=inp
    endif

 return res

endfunction 

 



fun! base#readdatalist(id)
    
    let list=base#readdatfile({ "file" : file, "type" : "List" })

endfun

fun! base#readdatfile(ref,...)

 let opts={ 'type' : 'List' }

 if a:0 
    if base#type(a:1) == 'Dictionary'
        call extend(opts,a:1)
    endif
 endif

 if base#type(a:ref) == 'String'
   if base#varhash#haskey('datfiles',a:ref)
      let file = base#varhash#get('datfiles',a:ref,'')
   else 
      return []
   endif
 elseif base#type(a:ref) == 'Dictionary'
   call extend(opts,a:ref)
   let file=a:ref['file']
   if exists("a:ref['type']")
        let opts.type = a:ref['type']
   endif
 endif

 if opts.type == 'Dictionary'
    let ref=opts
    call extend(ref,{ 'file' :  file } )
    let res=base#readdict( ref )
 elseif opts.type == 'List'
    let res=base#readarr(file,opts)
 endif

 return res

endf


fun! base#readarr(file,...)

  let file=a:file

  let opts={ 
    \   'splitlines'    : 1      ,
    \   'uniq'          : 0      ,
    \   'select_fields' : 'all'  ,
    \   'sep'           : '\s\+' ,
    \   'joinsep'       : ' '    ,
    \   'sort'          : 0      ,
    \    }

  if a:0
    if base#type(a:1) == 'Dictionary'
        call extend(opts,a:1)
    endif
  endif

  if ! filereadable(file)
        return [] 
  endif

    let lines = readfile(file)
    let arr   = []
    
    for line in lines
        if line =~ '^\s*#'
            continue
        endif

        let vars=split(line,opts.sep)

        let sel_vars=[]
        if opts.select_fields == 'all'
            let sel_vars=copy(vars)
        else
            let sel_ids=split(opts.select_fields,',')
            for id in sel_ids
               if exists("vars[id]")
                   call add(sel_vars,vars[id])
               endif
            endfor
        endif

        if opts.splitlines 
            call extend(arr,sel_vars)
        else
            call add(arr,join(sel_vars,opts.joinsep))
        endif

    endfor

    if opts.uniq
       let arr=base#uniq(arr)
    endif

    if opts.sort
       let arr = sort(arr)
    endif
    
    return arr

endf

fun! base#readdict(ref)
 
  let ref=a:ref

  let opts={
    \   'value_type'    : 'String',
    \   'max_entry'     : -1,
    \   'sep'           : ' '  ,
    \   }

  if base#type(ref) == 'String'
     let opts['file']=ref
  elseif base#type(ref) == 'Dictionary'
     call extend(opts,ref)
  endif

  let lines=readfile(opts.file)

  let dict={}
  let sep=opts.sep
  let key=''

  let ientry=0

  for line in lines
    if line =~ '^\s*#'
      continue
    endif

    let vars=split(line,sep)

    if line =~ '^\w\+'
      let ientry+=1
      if ientry == opts.max_entry
         break
      endif
  
      let key=remove(vars,0)
    
          if opts.value_type == 'String'
            let val=join(vars,sep)
            let dict[key]=val
          elseif opts.value_type == 'List'
            let dict[key]=vars
          endif

    elseif line =~ '^\s\+'

        if len(key)
          if opts.value_type == 'String'
            let dict[key].=line
          elseif opts.value_type == 'List'
            call extend(dict[key],vars)
          endif
        endif

    endif

    let dict[key]=base#rmwh(dict[key])

  endfor

  return dict
 
endfun


" remove whitespaces from both ends
"

fun! base#rmwh(ivar)
 
  let var=a:ivar

  let var=substitute(var,'^\s*','','g')
  let var=substitute(var,'\s*$','','g')

  return var

endf

fun! base#prompt(msg,default,...)
  let [msg,default] = [ a:msg,a:default ]

  if !base#opttrue('prompt')
    return default
  endif

  let complete=get(a:000,0,'')

  if strlen(complete)
    let v = input(msg,default,complete)
  else
    let v = input(msg,default)
  endif

  return v
endf

fun! base#rmendssplitglob(pathkey,pat)

 let files=[]
 let modifiers=":p:t:r"
 let files=base#splitglob(a:pathkey, a:pat )

 call map(files,"fnamemodify(v:val,'" . modifiers . "')")
 let files=base#rmprefix(files)

 call filter(files,'len(v:val) > 0')

 return files

endf

fun! base#rmprefix(files)

  let files=[]

  let action = "substitute(v:val,'" . '^\(\w\+\)\.' . "','" . '' .   "','g')"
  let files  = map(a:files,action )

  return files

endf

function! base#gitcmds (...)
    return base#var('gitcmds')

endfunction

"call base#git (command,command-line options, path)

"call base#git ('add')
"call base#git ('add',options,path)

"call base#git(cmd,inopts,path)
"call base#git({ "cmds" : [ cmd ]})
"call base#git({ "cmds" : [ cmd ], "inopts" : inopts, "path" : path})

"call base#git({ 
  "\ "cmds" : [ cmd ], 
  "\ "inopts" : inopts, 
  "\ "gitopts" : { "git_prompt" : 0},
  "\ "path" : path
"\ })

function! base#git (...)
  let aa=a:000

  let cmd = ''
  let inopts = ''

    if a:0
        let ref     = get(aa,0,'')

    if base#type(ref) == 'String'
      let cmd = ref
      let inopts  = get(aa,1,'')
      let path    = get(aa,2,'')

    elseif base#type(ref) == 'Dictionary'
      let cmds = get(ref,'cmds',[])

      let inopts  = get(ref,'inopts','')
      let path    = get(ref,'path','')

      let gitopts = get(ref,'gitopts',{})
      unlet ref

      " Backup used git options
      let kept={}
      if len(gitopts)
        let kept = base#opt#get(keys(gitopts))
        call base#opt#set(gitopts)
      endif

      for cmd in cmds
        call base#git(cmd,inopts,path)
      endfor

      " Restore used git options
      if len(kept)
        call base#opt#set(kept)
      endif
      return
    endif
    else
        let cmd = base#getfromchoosedialog({ 
            \ 'list'        : base#gitcmds(),
            \ 'startopt'    : 'regular',
            \ 'header'      : "Available git cmds are: ",
            \ 'numcols'     : 1,
            \ 'bottom'      : "Choose git cmd by number: ",
            \ })
    endif

    let notnative=base#var('gitcmds_notnative')

    if base#inlist(cmd,notnative)
    else
    if base#opttrue('git_CD')
      if base#buf#type() != 'base#sys' 
            call ap#GoToFileLocation()
      endif
    endif

        let tmp     = tempname()

        let cmdopts = base#git#cmdopts()

    if strlen(inopts)
      let opts = inopts
    else
      let opts = get(cmdopts,cmd,'')
    endif

    if  base#inlist(cmd,base#qw('commit'))
      if !base#git#modified() 
         call base#warn({ 'text' : 'Repo Not Modified!'})
         return 
      endif
    endif

    if base#opttrue('git_prompt')
        let opts = input('Options for '.cmd.' command:',opts)
    endif
        let cmd_o  = cmd .' '.opts
    endif

    let so=[]

    if base#inlist(cmd,base#qw('rm add'))

        let fp     = expand('%:p')
        let gitcmd = 'git ' . cmd_o . ' ' . fp
        let files  = [fp]
    
        for f  in files
            call base#sys({ "cmds" : [gitcmd]})
            call extend(so,base#var('sysout'))
        endfor

"""git_save
    elseif base#inlist(cmd,base#qw('save'))
        let cmds=base#qw('commit pull push')

        let gitopts=base#qw('git_prompt git_split_output git_CD')
        if exists("ref") | unlet ref | endif
        let ref = { 
            \ 'git_prompt'       : 0,
            \ 'git_split_output' : 0,
            \ 'git_CD'           : 0,
            \ }
        let kept=base#opt#get(gitopts)
        call base#opt#set(ref)

				call base#echo({ 
					\ 'text'   : 'Saving to Git repo...',
					\ 'prefix' : '',
					\	})

        for cmd in cmds
            call base#git(cmd)
        endfor

        call base#opt#set(kept)

        return 
    elseif base#inlist(cmd,base#qw('send_to_origin'))
        let cmds=base#qw('commit push')
        for cmd in cmds
            call base#git(cmd)
        endfor
        return 
    elseif base#inlist(cmd,base#qw('get_from_origin'))
    elseif base#inlist(cmd,base#qw('add_thisfile'))
        let fpath=expand('%:p')
        call base#git('add',fpath)
    return

    elseif base#inlist(cmd,base#qw('submodule_foreach_git_pull'))
        let cmds=[
            \ 'git submodule foreach git pull'
            \ ]
        call base#git({ "cmds" : cmds })
        return 
    elseif base#inlist(cmd,base#qw('submodule_foreach_git_co_master'))
        let cmds=['git submodule foreach git co master']
        call base#git({ "cmds" : cmds })
        return 

    else
        let gitcmd = 'git ' . cmd_o

        
        let fulldir = getcwd()
        let dirname = fnamemodify(fulldir,':p:h:t')
    
        call base#var('stl_gitcmd_fulldir',fulldir)
        call base#var('stl_gitcmd_dirname',dirname)
        call base#var('stl_gitcmd_cmd',gitcmd)

        let exec = [ 
              \ 'call base#buf#type("base#sys")',
              \ 'setlocal nomodifiable',
              \ 'StatusLine gitcmd',
              \ ]

        let refsys = { "cmds" : [gitcmd], "exec" : exec }

        if base#opttrue('git_split_output')
            let refsp={ 
              \ "split_output" : 1,
              \ "split_output_cmds" : [ 
              \   'setf gitcommit' ,
              \   'StatusLine gitcmd' ,
              \ ],
              \   }
            call extend(refsys,refsp)
        endif

        call base#sys(refsys)
        call base#varset('gitcmd_out',base#varget('sysout',[]))

        call base#git#process_out({ 'cmd' : gitcmd })
           
    endif

    return 
    
endfunction

function! base#envcmd (...)

    if a:0
        let cmd = a:1
    endif
    let ok = base#sys({ "cmds" : [cmd], "split_output" : 1 })

    return ok

endfunction

function! base#powershell (...)
  let aa = a:000
  let pscmd = get(aa,0,'')

  if !len(pscmd)
    let pscmd = input('Powershell command:','','custom,base#complete#powershell')
    if !len(pscmd) | return | endif
  endif

  let cmd = 'powershell ' . pscmd

  let psopts_h={
      \ 'Get-NetTCPSetting' : base#qw('-Setting InternetCustom')
      \ ,
      \ }
  let psopts=get(psopts_h,pscmd,[])
  call base#var('psopts',psopts)

  let opts = input('Further options for powershell:','','custom,base#complete#psopts')
  while len(opts)
    let cmd.=' '.opts
    let opts = input('Further options for powershell:','','custom,base#complete#psopts')
  endw
    
  call base#envcmd(cmd)

endfunction

function! base#splitsystem (cmd)

  let lines = system(a:cmd)
  let arr   = split(lines,"\n")

  return arr

endfunction



fun! base#splitglob(...)
 
 let files=[]

 if base#type(a:1) == 'Dictionary'
   let ref=a:1

   let dir=ref['dir']
   let pat=ref['pat']

 elseif base#type(a:1) == 'String'
   if a:0 == 2

    let pathkey=a:1
    let pat=a:2

   endif
 endif

 if exists('dir')
  let files=split(glob(dir . '/' . pat ),"\n")
 elseif exists('pathkey')
  let files=split(glob(base#catpath(pathkey,pat)),"\n")
 endif

 return files

endf



fun! base#basenamesplitglob(pathkey,pat)
 
 let files=[]
 let files=base#fnamemodifysplitglob(a:pathkey, a:pat, ':p:t' )

 return files

endf


fun! base#fnamemodifysplitglob(...)

 let files=[]

 if base#type(a:1) == 'Dictionary'
   let ref       = a:1
   let files     = base#splitglob(ref)
   let modifiers = ref.modifiers

 elseif base#type(a:1) == 'String'
   if a:0 == 3 

    let pathkey   = a:1
    let pat       = a:2
    let modifiers = a:3

    let files=base#splitglob(pathkey, pat )

   endif
 endif

 if len(files)
  call map(files,"fnamemodify(v:val,'" . modifiers . "')")
 endif

 return files

endf


fun! base#mapsub(array,pat,subpat,subopts)

  let arr=copy(a:array)

  call map(arr,"substitute(v:val,'" . a:pat .  "','" . a:subpat . "','" . a:subopts . "')")

  return arr
endf

function! base#varreset(varname,new)

 let varname=substitute(a:varname,'^[g:]*','g:','g')

 if  exists(varname)
   exe 'unlet ' . varname
 endif

 exe 'let ' . varname . '=a:new'
 
endfunction

 
fun! base#readdictdat(ref)
 
 let ref=a:ref

 let opts={}

 call base#varcheckexist('datfiles')

 if base#type(ref) == 'String'
   let opts['file']=s:datfiles[ref]
 elseif base#type(ref) == 'Dictionary'
   if has_key(ref,'dat')
     let opts['file']=s:datfiles[ref['dat']]
   endif
   call extend(opts,ref)
 endif

 let dict=base#readdict(opts)

 return dict
endfun

"""base_find
function! base#find(ref)

    " list of found files to be returned
    let files = []

    if has('perl')
        let files = base#findbyperl(a:ref)
    else
        if has('win32')
            let files = base#findwin(a:ref)
        else
            let files = base#findunix(a:ref)
        endif
    endif

    return files

endf

"""base_findwin 

" echo base#find({ "cwd" : 1, "exts" : [ "vim" ]})
" echo base#find({ "cwd" : 1, "exts" : [ "vim" ]})
" echo base#find({ "subdirs" : 1, "exts" : [ "vim" ]})
" echo base#find({ "subdirs" : 1})
" echo base#find({ "subdirs" : 1, "pat": "^a" })
"
function! base#findwin(ref)
    let ref = a:ref

    let dirs = []
    let exts_def = [ '' ] 

    let do_subdirs = get(ref,'subdirs',1)

    let exts = get(ref,'exts',exts_def)
    if ! len(exts) | let exts=exts_def | endif

    let qw_exts = get(ref,'qw_exts','')
    if len(qw_exts)
      let exts = base#qw(qw_exts)
    endif

    let dirs = get(ref,'dirs',dirs)
    
    let searchopts = ' /b/a:-d '

    if get(ref,'cwd')
        call add(dirs,getcwd())
    endif

    let dirids = []
    let qw_dirids = get(ref,'qw_dirids','')
    if len(qw_dirids)
      let dirids = base#qw(qw_dirids)
    endif

    let dirids = get(ref,'dirids',dirids)
    for id in dirids
        let dir = base#path(id)
        if len(dir)
          call add(dirs,dir)
        endif
    endfor

    if do_subdirs 
        let searchopts .= ' /s '
    endif

    " list of found files to be returned
    let foundfiles = []

    let olddir = getcwd()
    
    for dir in dirs
        let found = ''
        let dir = substitute(dir,'/','\','g')

        let dir = base#file#std(dir)

        if !isdirectory(dir)
            continue
        else
            exe 'cd ' . dir
        endif

        for ext in exts 
            if strlen(ext) | let ext = '.'.ext | endif

            "let searchcmd  = 'dir ' .dir.'\*'.ext.searchopts 
            let searchcmd  = 'dir *'.ext.searchopts 

            let ok  = base#sys( { "cmds" : [ searchcmd ], "skip_errors"  : 1 } )
            let res = base#var('sysoutstr')

            if ( ok && ( res !~ '^File Not Found' ) )
                let found .= res . "\n"
            endif

        endfor

        let files=split(found,"\n")
        call filter(files,'v:val != ""')

        if ! do_subdirs
            call map(files,'base#file#catfile([dir, v:val])')
        endif

        let diru = base#file#win2unix(dir)
        let newfiles=[]


        for file in files
            let add=1
            let cf = copy(file)

            let cfunix = base#file#win2unix(cf)
            let cfrelunix = substitute(cfunix,'^' . diru . '[/]*','','g') 
            let cfrel = base#file#unix2win(cfrelunix)

            if get(ref,'relpath')
                let cf = cfrel
            endif

            if get(ref,'rmext')
                for ext in exts
                    let cf = substitute(cf,'\.'.ext.'$','','g') 
                endfor
            endif

            let fnm = get(ref,'fnamemodify','')
            if strlen(fnm)
                let cf = fnamemodify(cf,fnm)
            endif

            let cfname = fnamemodify(cf,':p:t')

            let pat = get(ref,'pat','')
            if strlen(pat)
                if ( cfname !~ pat )
                    let add=0
                endif
            endif

            if add
                call add(newfiles,cf)
            endif
        endfor

        let map = get(ref,'map','')
        if strlen(map)
            call filter(newfiles,"'" . map . "'")
        endif

        let files = newfiles
        call extend(foundfiles,files)
    endfor

    exe 'cd ' . olddir

    return foundfiles

endf

"""base_findunix
 
" input: Dictionary
" return: List

fun! base#findunix(ref)

    let prefix="(base#findunix) "
    if ( base#type(a:ref) != 'Dictionary' )
        call base#warn({ 
            \   "text" : "Need provide input parameter as dictionary", 
            \   "prefix" : prefix })
        return
    endif

 if has('win32')
    return
 endif

 let opts={
        \   'dir'       : '.',
        \   'path'      : '',
        \   'ext'       : '',
        \   'type'      : '',
        \   'startpattern'   : '',
        \   'sort'      : 1,
        \   'maxdepth'  : '',
        \   'mindepth'     : '',
        \   'fnamemodify'  : '',
        \   'map'          : '',
        \   'fileroot'     : 0,
        \   'relpath'      : 0,
        \   }
  
 call extend(opts,a:ref)

 if len(opts.path)
    let opts.dir=base#catpath(opts.path,'')
 endif

 if opts.fileroot
    let opts.fnamemodify=':p:t:r'
 endif

 if ! isdirectory( fnamemodify(opts.dir,':p') )
    call base#subwarn('Directory does not exist: ' . opts.dir)
    return
 endif

 let cmds=[]

 if strlen(opts.ext)
    let exts=split(opts.ext,',')
    for ext in exts
      call add(cmds,opts.dir . ' -name ' . opts.startpattern . '\*.' . ext )
    endfor

 else
    let cmds=[ opts.dir ]
 endif

 let knowntypes=[ 'd' , 'f' ]
 if strlen(opts.type) && base#inlist( opts.type, knowntypes )
    call map(cmds,"v:val . ' -type ' . opts.type"  )
 endif

 if strlen(opts.maxdepth)
    call map(cmds,"v:val . ' -maxdepth ' .  opts.maxdepth ")
 endif

 if strlen(opts.mindepth)
    call map(cmds,"v:val . ' -mindepth ' .  opts.mindepth ")
 endif
 
 let foundfiles=[]

 for cmd in cmds
    call extend(foundfiles,base#splitsystem('find ' . cmd))
 endfor

 if strlen(opts.fnamemodify)
    call map(foundfiles,"fnamemodify(v:val,'" . opts.fnamemodify . "')" )
 endif

 if opts.sort
    let foundfiles=sort(foundfiles)
 endif

 if opts.relpath
    call map(foundfiles,"substitute(v:val,'^' . opts.dir . '[/]*','','g') ")
 endif

 echo opts.map

 if opts.map
    call map(foundfiles,"'" . opts.map . "'")
 endif

 call filter(foundfiles,"v:val != '' ")

 return foundfiles
endf

 
function! base#echoredraw(text,...)

  let hl='MoreMsg'

  if a:0
    let hl=a:1
  endif

  redraw!
  exe 'echohl ' . hl
  echo a:text
  exe 'echohl None'

endfunction

 
function! base#readdatpaths(ref)
    let ref=a:ref

    call base#varcheckexist([ 'pathsep', 'paths' ])

    let res={}
    
    let lines=readfile(ref.file)
    
    for line in lines
    
        let rootdir=ref.rootdir
        
        if line =~ '^\s*#' || line =~ '^\s*$'
            continue
        endif
        
        let vars = split(line,'\s\+')
        let dat  = remove(vars,0)
        
        if len(vars)
            let rootdir=remove(vars,0)
            
            let rootdir=substitute(rootdir,'_\(\w\+\)_','\1','g')
            let rootdir=base#path(rootdir)
        endif
        
        if len(vars)
            let subdirs=vars[0] . '/'
            let subdirs=substitute(subdirs,'[\/]*$','/','g')
        else 
            let subdirs=''
        endif
        
        let datfile=base#file#catfile([  
            \   rootdir, subdirs . dat . ref.ext
            \   ])
        
        let res[dat]=datfile
    
    endfor
    
    return res

endfunction

 
fun! base#setglobalvarfromdat(ref,...)

 let ref=a:ref

 let opts={}
 if a:0
   let opts=a:1
 endif

 if type(ref) == type("")
     let varname = ref
 elseif type(ref) == type([])
     for dat in ref
         call base#setglobalvarfromdat(dat,opts)
     endfor

     return
 endif

 let varname=substitute(varname,'^g:','','g')

 if exists("g:" . varname)
    exe 'unlet g:' . varname
 endif

 if ! len(keys(opts))
    let cmd= 'let g:' . varname . "=base#readdatfile('" . varname . "')"
 else
    let cmd= 'let g:' . varname . "=base#readdatfile('" . varname . "', opts )"
 endif

 exe cmd
 
endfun

 
fun! base#getfileinfo(...)

 let g:path=''

 let ids=[ '<afile>', '<buf>', '%' ] 
 
 while !filereadable(g:path) && len(ids)
    let id     = remove(ids,-1)
    let g:path = expand(id . ':p')
 endwhile

 if !filereadable(g:path)
    return
 endif

 let g:dirname  = fnamemodify(g:path,':h')
 let g:filename = fnamemodify(g:path,':t')

 " root filename without all extensions removed
 let g:filename_root = get(split(g:filename,'\.'),0)

 let g:ext = fnamemodify(g:path,':e')

 let fileinfo={
    \   'path'          : g:path          ,
    \   'ext'           : g:ext           ,
    \   'filename'      : g:filename      ,
    \   'dirname'       : g:dirname       ,
    \   'filename_root' : g:filename_root ,
    \   }
 let g:fileinfo=fileinfo
 let b:fileinfo=fileinfo

 return fileinfo

endfun

" pass command to be executed as String
"" base#sys(cmd)

" pass commands to be executed as List
"" base#sys([ cmd1, cmd2 ])

" specify a custom error message 
"" base#sys(ref, error_message)

"" base#sys({ "cmds" : [ ... ]}, error_message)

fun! base#sys(...)

 let cmds=[]

 let opts={
    \   'custom_error_message': 0   ,
    \   'show_output'  : 0          ,
    \   'prompt'       : 1          ,
    \   'skip_errors'  : 0          ,
    \   'split_output'  : 0         ,
    \   }

 if a:0 
   if base#type(a:1) == 'String'
    let cmd=a:1
    let cmds=[ cmd ] 
    
   elseif base#type(a:1) == 'List'
    let cmds=a:1

   elseif base#type(a:1) == 'Dictionary'
    let ref = a:1
    let cmds = get(ref,'cmds',[])
    call extend(opts,ref)
    
   endif
    
     if a:0 >= 2
            let errormsg=a:2
            let opts.custom_error_message=1
     else
            let errormsg="ERROR> Error while executing shell command: "
     endif
 endif

 let ok=1

 let output=[]
 let outputstr=''

 for cmd in cmds 
    let outstr = system(cmd)
    let out    = split(outstr,"\n")

    call extend(output,out)
    let outputstr .= outstr

    if get(opts,'skip_errors',0)
        continue
    endif
    if v:shell_error
        echohl ErrorMsg
        echo errormsg
        if opts.custom_error_message == 0
            echo cmd
        endif
        echohl None

        if get(opts,'prompt',0)

            let show_output = input('Show the tail of the command output (y/n)? : ','y')
            let nlines = len(output) < 10 ? len(output) : input('Number of lines to be shown from the bottom: ',10)
            if show_output == 'y' 
                let i = len(output) - nlines 
                let i = ( i < 0 ) ? 0 : i

                echo ' '
                while i < len(output)
                    echohl WildMenu
                    echo output[i]
                echohl None
                    let i += 1
                endw
            endif

        endif

        let ok=0
    endif
 endfor

 call base#varset('sysout',output)
 call base#varset('sysoutstr',outputstr)

 if get(opts,'split_output',0)
    let so_cmds=get(opts,'split_output_cmds',[])

    split
    enew

    call append(0,output)

    if len(so_cmds)
       for cmd in so_cmds
           exe cmd
       endfor
    endif

    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nomodifiable

 endif

 return ok

endfun


function! base#pathset (ref)

  if ! exists("s:paths") | let s:paths={} | endif

    for [ pathid, path ] in items(a:ref) 
        let e = { pathid : path }
        call extend(s:paths,e)
    endfor

    let pathlist = sort(keys(s:paths))
    call base#varset('pathlist',pathlist)

endfun

function! base#append (...)
  let opt = get(a:000,0,'')

  let sub = 'base#append#'.opt
	try
    exe 'call '.sub.'()'
	catch 
		call base#warn({ 
			\	'text' : 'Failure to execute: ' . sub 
			\	} )
	endtry
	
endfunction

function! base#pathlist ()
    if ! exists("s:paths")
        let s:paths={}
    endif

    let pathlist = sort(keys(s:paths))
    call base#var('pathlist',pathlist)

    return pathlist
    
endfunction

function! base#pathids (path)
    let path = a:path
    let ids =[]
    for id in base#pathlist()
        let rdir = base#file#reldir(path,base#path(id))
        if strlen(rdir)
            call add(ids,id)
        endif
    endfor

    return ids
endfunction

"""base_path

" base#path('funs')
function! base#path (pathid)
    let prefix='(base#path) '

    if !exists("s:paths")
        call base#initpaths()
    endif

    if exists("s:paths[a:pathid]")
        let path = s:paths[a:pathid]
    else
        let path = ''

        call base#warn({ 
            \   "text"   : "path undefined: " . a:pathid ,
            \   "prefix" : prefix ,
            \   })
    endif
    
    return path
    
endfunction

"""base_warn
"
"  base#warn({ "text" : "aaa" })
"  base#warn({ "text" : "aaa", "prefix" : ">>> " })
"
function! base#warn (ref)
    let text = ''

    let text = a:ref['text']

  let prefix    = base#echoprefix()

    if exists("a:ref['prefix']")
        let prefix = a:ref['prefix']
    endif

    let text = prefix . text

    echohl WarningMsg
    echo text
    echohl None
    
endfunction

function! base#info (...)

 call base#echoprefix('(base#info)')

 let topic='all'
 if a:0
   let topic=a:1
 endif

 let g:hl      = 'MoreMsg'
 let indentlev = 2
 let indent    = repeat(' ',indentlev)

 call base#varcheckexist('info_topics')

 if topic == 'all'
   for topic in base#var('info_topics') 
        call base#info(topic)
   endfor
 else

"""info_file
   if topic == 'file'
       call base#echo({ 'text' : "Current file: " } )
       echo indent . expand('%:p')

       call base#echo({ 'text' : "Current directory: " })
       echo indent . expand('%:p:h')

       call base#echo({ 'text' : "Filetype: " } )
       echo indent . &ft

       call base#echo({ 'text' : "Other variables: " } )
       call base#echovar({ 'var' : 'g:dirname', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:filename', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:path', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:ext' , 'indent' : indentlev })

"""info_perlapp
   elseif topic == 'perlapp'
       call base#echo({ 'text' : "PerlApp options: " } )
       call base#varecho('perlmy_perlapp_opts')

"""info_git
   elseif topic == 'git'
       call base#echo({ 'text' : "Git: " } )

       call base#varecho('gitinfo')

"""info_grep
   elseif topic == 'grep'
       call base#echo({ 'text' : "Grep configuration: " } )

       call base#echo({ 'text' : " "  } )
       call base#echo({ 'text' : " &grepformat    => " . &grepformat } )
       call base#echo({ 'text' : " &grepprg       => " . &grepprg } )
       call base#echo({ 'text' : " "  } )
       call base#echo({ 'text' : " base#grepopt   => " . base#grepopt() } )
       call base#echo({ 'text' : " "  } )

"""info_bufs
   elseif topic == 'bufs'

       call base#echo({ 'text' : "Buffer-related stuff: " } )
       call base#echo({ 'text' : " "  } )
       call base#echo({ 'text' : " BuffersList     - list buffers"  } )
       call base#echo({ 'text' : " BuffersWipeAll  - wipe out all buffers except the current one"  } )
       call base#echo({ 'text' : " "  } )
       call base#echo({ 'text' : " --- current buffer --- "  } )
       call base#echo({ 'text' : " "  } )

       let ex_finfo = exists('b:finfo')
       let ex_bbs   = exists('b:base_buf_started')

       call base#echo({ 'text' : " b:finfo exists => " . ex_finfo  } )
       call base#echo({ 'text' : " b:base_buf_started exists => " . ex_bbs  } )

       if ex_finfo
            call base#echo({ 'text' : " b:finfo  => "  } )
            echo b:finfo
       endif

       call base#echo({ 'text' : " "  } )

       let pathids =  base#buf#pathids ()
       call base#echo({ 'text' : " pathids => " . join(pathids,' ')  } )

"""info_tagbar
   elseif topic == 'plg_tagbar'
       call base#echo({ 'text' : "Tagbar variables: " } )

        let vars = base#var('tagbar_vars')
        for v in vars
            let val = ''
            let gv  = "g:tagbar_" . v 
            if exists(gv)
                exe 'let val = ' . gv
            endif

            call base#echo({ 'text' : "\t" . v . " =>" . val } )
        endfor

"""info_lasu
   elseif topic == 'lasu'
       call base#echo({ 'text' : "LASU configuration: " } )

       call base#echo({ 'text' : "   Variable values: ", 'hl' : 'Title' } )

       let vars = base#qw('lasu_datfiles lasu_datlist')
       for var in vars
            call base#varecho(var)
       endfor

"""info_latex
   elseif topic == 'latex'
       call base#echo({ 'text' : "LaTeX configuration: " } )

"""info_statusline
   elseif topic == 'statusline'
    let stl=''
    if exists("g:F_StatusLine")
        let stl = g:F_StatusLine
    endif

    let stl    = base#var('stl')
    let stlopt = base#var('stlopt')

       call base#echo({ 'text'   : "Statusline: " } )
       call base#echo({ 'text'   : " " } )
       call base#echo({ 'text'   : "\t"."stlopt               =>  " .stlopt } )
       call base#echo({ 'text'   : " " } )
       call base#echo({ 'text'   : "\t"."g:F_StatusLine       =>  " . stl } )
       call base#echo({ 'text'   : "\t"."&stl                 =>  " . &stl } )
       call base#echo({ 'text'   : "\t"."stl (StatusLine cmd) =>  " . stl } )
       call base#echo({ 'text'   : " " } )

"""info_paths
   elseif topic == 'paths'

       call base#echo({ 'text'   : "Paths-related variables: " } )
       call base#echo({ 
        \   'text'   : 'pathlist => ' 
            \   . "\n\t" . join(base#pathlist()," "), 
        \   'indentlev' : indentlev })

"""info_dirs
   elseif topic == 'dirs'

       call base#echo({ 'text'   : "Directory-related variables: " } )
       call base#echovar({ 'var' : 'g:dirs', 'indent' : indentlev })

"""info_env
   elseif topic == 'env'
     call base#echo({ 'text' : "ENVIRONMENT ", 'hl' : 'Title' } )

     call base#sys({ "cmds" : [ 'env' ]})

     let evlist = base#envvarlist()
     echo evlist


"""info_encodings
   elseif topic == 'encodings'
     call base#echo({ 'text' : "ENCODINGS ", 'hl' : 'Title' } )

     if exists("&encoding")
       call base#echo({ 'text' : "Encoding: " } )
       call base#echovar({ 'var' : '&enc', 'indent' : indentlev })
     endif

     if exists("&fileencoding")
       call base#echo({ 'text' : "File encoding: " } )
       call base#echovar({ 'var' : '&fenc', 'indent' : indentlev })
     endif

     if exists("&fileencodings")
       call base#echo({ 'text' : "File encodings: " } )
       call base#echovar({ 'var' : '&fileencodings', 'indent' : indentlev })
     endif

"""info_completions
   elseif topic == 'completions'
       call base#echo({ 'text' : "COMPLETIONS ", 'hl' : 'Title' } )

       call base#echo({ 'text' : "OMNI Completion: " } )
       call base#echovar({ 'var' : 'g:OMNI_CompNames', 'indent' : indentlev })
       call base#echovar({ 'var' : '&omnifunc', 'indent' : indentlev })

       call base#echo({ 'text' : "Dictionary completion: " } )
       call base#echovar({ 'var' : '&dict', 'indent' : indentlev })

       call base#echo({ 'text' : "Completion options: " } )
       call base#echovar({ 'var' : '&complete', 'indent' : indentlev })
       call base#echovar({ 'var' : '&completeopt', 'indent' : indentlev })
       call base#echovar({ 'var' : '&completefunc', 'indent' : indentlev })

"""info_tags
   elseif topic == 'tags'
       let tags = join(split(&tags,","),"\n\t")

       let tgs = base#tg#ids_comma()

       call base#echo({ 'text' : "Tags: " } )
       call base#echo({ 'text' : " &tags => \n\t" . tags } )
       call base#echo({ 'text' : "Tag ID: " } )
       call base#echo({ 'text' : " tgids => \n\t\t" . tgs } )

"""info_perl
   elseif topic == 'perl'
        let perllib = base#envvar('PERLLIB')
        let perllib = join(split(perllib,";"),"\n\t")

        call base#echo({ 'text' : "Perl-related: " } )
        call base#echo({ 'text' : "$PERLLIB => \n\t" . perllib  } )

        let perlexes=join(base#f#path('perl'),"\n\t")
        call base#echo({ 'text' : "Perl Executables:"   } )
        call base#echo({ 'text' : "  perlexes => \n\t" . perlexes } )

"""info_proj
   elseif topic == 'proj'
        call projs#info()

   elseif topic == 'proj_usedpacks'
        call projs#info#usedpacks()
       
   elseif topic == 'perl'
       call base#echo({ 'text' : "PERL ", 'hl' : 'Title' } )

       if exists("g:PMOD_ModuleName")
           call base#echo({ 'text' : "Current Perl module: " } )
           call base#echovar({ 'var' : 'g:PMOD_ModuleName', 'indent' : indentlev })
       endif

       if exists("g:perlfileinfo")
           call base#echo({ 'text' : "Last loaded Perl file info: " } )
           call base#echovar({ 'var' : 'g:perlfileinfo', 'indent' : indentlev })
       endif

       if exists("g:PMOD_ModuleDir")
           call base#echo({ 'text' : "Current Perl module root directory: " } )
           call base#echovar({ 'var' : 'g:PMOD_ModuleDir', 'indent' : indentlev })
       endif

"""info_keymap
   elseif topic == 'keymap'
       call base#echo({ 'text' : "KEYMAP: " } )
       call base#echo({ 'text' : "&keymap =>  " . &keymap,'indentlev' : indentlev })

"""info_rtp
   elseif topic == 'rtp'
       let rtp = "\t" . join(split(&rtp,","),"\n\t")

       call base#echo({ 'text' : "RUNTIMEPATHS: " } )
       call base#echo({ 'text' : "&rtp =>  " . rtp,'indentlev' : indentlev })

"""info_plugins
   elseif topic == 'plugins'
    
       call base#echo({ 'text' : "PLUGINS: " } )
       call base#echo({ 'text' : "g:plugins =>  " 
        \   . "\n\t" . join(g:plugins,"\n\t"),'indentlev' : indentlev })


"""info_make
   elseif topic == 'make'
       call base#echo({ 'text' : "MAKE: " } )
       call base#echovar({ 'var' : '&makeprg', 'indent' : indentlev })
       call base#echovar({ 'var' : '&efm', 'indent' : indentlev })
       call base#echovar({ 'var' : '&makeef', 'indent' : indentlev })

       call base#echo({ 
        \   'text' : "makeprg id =>  " 
        \   . make#var('makeprg') }) 

       call base#echo({ 
        \   'text' : "efm id     =>  " 
        \   . make#var('efm') }) 

       call base#echo({ 
        \   'text' : "cwd        =>  " 
        \   . getcwd() }) 

"""info_opts
   elseif topic == 'opts'
       call base#echo({ 'text' : "OPTIONS: " } )
       call base#varcheckexist('opts')

       call base#varecho('opts')
       call base#varecho('opts_saved')

   endif
 endif

 call base#echoprefixold()
 
endfun

fun! base#echoprefix(...)
    if !exists("s:echoprefix")
        let s:echoprefix=''
    else
        let s:echoprefixold=s:echoprefix
    endif

    if a:0
        let s:echoprefix = a:1
    endif

    return s:echoprefix
    
endf

fun! base#echoprefixold(...)
    if !exists("s:echoprefixold")
        let s:echoprefix=''
    else
        let s:echoprefix=s:echoprefixold
    endif

    return s:echoprefix
    
endf

fun! base#echo(opts)
  let opts=a:opts

  let prefix = ''
  let prefix    = base#echoprefix()
  let indentlev = 0

  if exists("opts.indentlev")
    let indentlev=opts.indentlev
  endif
  let indent    = repeat(' ',indentlev)

  let hl='MoreMsg'
  if exists("g:hl")
     let hl=g:hl
  endif
  if exists("opts.hl")
     let hl=opts.hl
  endif
  if exists("opts.prefix")
     let prefix=opts.prefix
  endif

  exe "echohl " . hl
  echo indent . prefix . opts.text
  exe "echohl None"

endf

 
fun! base#echovar(ref)

 let spliton=''
 let indentlev=2

 if base#type(a:ref) == 'String'
   let varname=a:ref

 elseif base#type(a:ref) == 'List'
   
 elseif base#type(a:ref) == 'Dictionary'
   let varname   = a:ref.var
   if exists("a:ref['indent']")
        let indentlev = get(a:ref,'indent')
   endif
   let spliton   = get(a:ref,'spliton')
   
 endif
   
 let indent=repeat(' ',indentlev)
 let vartype=''

 if exists(varname)
  let val=varname 
  exe 'let vartype=base#type(' . varname . ')'
 else
  let val="'undef'"
 endif

 let cmds=[]

 if vartype == 'String'

    if spliton
        call add(cmds, 'echo ' . "'" . indent . varname . ' = ' )
        exe 'let splitted=split(' . varname . ",'" . spliton . "')"
    else
      call add(cmds, 'echo ' . "'" . indent . varname . "  =  ' . " . val )
    endif

    if exists("splitted")
      for s in splitted
        call add(cmds,"echo '" . s . "'" )
      endfor
    endif

 elseif vartype == 'List'
    let cmd='echo ' . "'" . indent . varname . "  =  ' . join( " . val . ")"
    let cmds=[ cmd ] 

 elseif vartype == 'Dictionary'
    let cmd='echo ' . "'" . indent . varname . ' = ' . "'" . val 
    let cmds=[ cmd ] 

 endif

 for cmd in cmds
    exe cmd
 endfor
 
endfun


function! base#plgdir ()
    return base#var('plgdir')
endf    

"" let dd = base#datadir()
"" call base#datadir('aaa')

function! base#datadir (...)
    if a:0
        let datadir = a:1
        return base#var('datadir',datadir)
    endif

    return base#var('datadir')
endf    

" go to base plugin root directory

function! base#plgcd ()
    let dir = base#plgdir()
    exe 'cd ' . dir
endf    

function! base#envvar (varname)

    let var  = '$' . a:varname
    let val  = ''

    if exists(var)
        exe 'let val = ' . var
    endif

    return val

endf    

function! base#var (...)
    if a:0 == 1
        let var = a:1
        return base#varget(var)
    elseif a:0 == 2
        let var = a:1
        let val = a:2
        return base#varset(var,val)
    endif
endfunction

"""base_varecho
function! base#varecho (varname,...)
    let val =  base#var(a:varname)

    let ref = { 'text' : a:varname .' => '. base#dump(val),'prefix':'' }
    if a:0
        if base#type(a:1) == 'Dictionary'
            call extend(ref,a:1)
        endif
    endif
    call base#echo(ref)

endfunction

function! base#dump (...)
    let val = a:1
    let dump =''

    if exists("*PrettyPrint")
        let dump = PrettyPrint(val)
    endif

    if base#type(val) == 'Dictionary'
    elseif base#type(val) == 'String'
    elseif base#type(val) == 'List'
          
    endif

    return dump
endfunction

function! base#varget (varname,...)

    if ! exists("s:basevars")
        let s:basevars={}
    endif
    
    if exists("s:basevars[a:varname]")
        let val = copy( s:basevars[a:varname] )
    else
        let val = ''
    if a:0
        unlet val | let val = a:1
    endif
    endif

    return val
    
endfunction

function! base#varset (varname, value)

    if ! exists("s:basevars")
        let s:basevars={}
    endif

    if exists("s:basevars[a:varname]")
        unlet s:basevars[a:varname]
    endif
    let s:basevars[a:varname] = a:value
    
endfunction

function! base#varexists (varname)
    if exists("s:basevars")
        if exists("s:basevars[a:varname]")
            return 1
        else
            return 0
        endif
    else
        return 0
    endif
    
endfunction

function! base#varsetfromdat (...)
    let varname = a:1

    let type = "List"
    if a:0 == 2
        let type = a:2
    endif

    let datafile = base#datafile(varname)

    if !filereadable(datafile)
        call base#warn({ 
            \   "text": 'NO datafile for: ' . varname 
            \   })
        return 0
    endif

    let data = base#readdatfile({ 
        \   "file" : datafile ,
        \   "type" : type ,
        \   })

    call base#varset(varname,data)

    return 1

endfunction

function! base#datafile (id)
    let files = base#datafiles(a:id)
    let file = get(files,0,'')
    return file
endfunction

function! base#datafiles (id)

    let datadir = base#datadir()
    let file = a:id . ".i.dat"

    let files = base#find({
        \ "dirs"    : [ datadir ],
        \ "subdirs" : 1,
        \ "pat"     : '^'.file.'$',
        \   })

    return files

endfunction

function! base#initvarsfromdat ()

		let refdef = {}
		let ref    = refdef
		let refa   = get(a:000,0,{})

    call extend(ref,refa)

    let datfiles = base#varget('datfiles',{})
    let datlist  = base#varget('datlist',[])

    let dir = base#datadir()
    let dir = get(ref,'dir',dir)

    let mp = { "list" : "List", "dict" : "Dictionary" }
    for type in base#qw("list dict")
        let dir = base#file#catfile([ base#datadir(), type ])
        let vars= base#find({ 
            \   "dirs" : [ dir ], 
            \   "exts" : [ "i.dat" ],   
            \   "subdirs" : 1, 
            \   "relpath" : 1,
            \   "rmext"   : 1, })
        let tp = mp[type]
        for v in vars
            call base#varsetfromdat(v,tp)
            let d = []

            let dfs = base#find({ 
                \   "dirs" : [ dir ], 
                \   "exts" : [ "i.dat" ],   
                \   "subdirs" : 1, 
                \   "pat"     : v, })

            let df = get(dfs,0,'')

            call add(datlist,v)
            call extend(datfiles,{ v : df }) 
        endfor
    endfor

    call base#varset('datlist',datlist)
    call base#varset('datfiles',datfiles)
    
endfunction

function! base#initvars (...)
    call base#echoprefix('(base#initvars)')

    call base#initvarsfromdat()

  call base#var('opts_keys',sort( keys( base#var('opts') )  ) )

    call base#var('vim_funcs_user',
        \   base#fnamemodifysplitglob('funs','*.vim',':t:r'))

    call base#var('vim_coms',
        \   base#fnamemodifysplitglob('coms','*.vim',':t:r'))

    let varlist = keys(s:basevars)

    call base#var('varlist',varlist)

    if $COMPUTERNAME == 'OPPC'
        let v='C:\Users\op\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe'
    call base#varset('pdfviewer',v)
    endif

    call base#echoprefixold()
endf    

function! base#varlist ()
    let varlist = keys(s:basevars)
    call base#var('varlist',varlist)
    return varlist
endfunction

function! base#initplugins (...)

    call base#varsetfromdat('plugins','List')

    if exists('g:plugins') | unlet g:plugins | endif
    let g:plugins=base#varget('plugins',[])

		echo '--- base#initplugins ( plugins initialization ) --- '
		echo 'Have set the value of g:plugins'
		echo 'Have set the value of base variable "plugins" (check it via BaseVarEcho plugins)'
		echo '--------------------------------------------------- '

endf    


function! base#init (...)

  if a:0
    let opt = a:1
    if opt == 'cmds'
        call base#init#cmds()
    elseif opt == 'vars'
        call base#initvars()
    elseif opt == 'tagids'
        call base#init#tagids()

    elseif opt == 'menus'
        call base#menus#init()
    elseif opt == 'stl'
        call base#stl#setparts()
    elseif opt == 'files'
        call base#initfiles()
    elseif opt == 'plugins'
        call base#initplugins()
    elseif opt == 'paths'
        call base#initpaths()
    elseif opt == 'omni'
        call base#omni#init()
    endif
    return
  endif

    " initialize data using base#pathset(...)
    call base#initpaths()

    call base#tg#init()

    call base#initplugins()

    call base#initvars()
    call base#omni#init()

    call base#pap#list()

    " initialize data using base#f#set(...)
    call base#initfiles()

    call base#init#au()
    call base#init#cmds()

    "" initialize allmenus
    call base#menus#init()

    call base#rtp#update()

    call base#stl#setlines()
    
    return 1

endfunction

function! base#mkdir (dir)

  if isdirectory(a:dir)
    return  1
  endif

  try
    call mkdir(a:dir,'p')
  catch
    call base#warn({ "text" : "Failure to create dir: " . a:dir})
  endtry

endf


function! base#viewdat (...)
            
  if a:0
    let dat=a:1
  else
    let dat=base#getfromchoosedialog({ 
        \ 'list'        : base#varhash#keys('datfiles'),
        \ 'startopt'    : '',
        \ 'header'      : "Available DAT files are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose DAT file by number: ",
        \ })
  endif

  let datfiles=base#varget('datfiles')

  if has_key(datfiles,dat)
    let datfile=datfiles[dat]
  else
    call base#subwarn("Given dat file does not exist in s:datfiles dictionary")
  endif

  call base#fileopen(datfile)
endf

 
"
"   base#listnewinc(start,end,inc)
"

function! base#listnewinc(start,end,inc)

 let a=[]

 let i=0
 let counter=a:start

 while counter < a:end+1
   call add(a,counter)

   let counter+=a:inc
   let i+=1
 endw

 return a

endfunction

fun! base#listnew(...)

  let sz=a:1

  let i=0
  let a=[]

  while i<sz
   call add(a,'')
   let i+=1
  endw

  return a
 
endfun

"call base#grep({ "pat" : pat, "files" : [ ... ]  })
"call base#grep({ "pat" : pat, "files" : files })
"
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'plg_findstr' })
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'grep' }) - todo 
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'vimgrep' }) -todo

function! base#grep (...)
    let ref = {}
    if a:0 | let ref = a:1 | endif

    let opt = base#grepopt()

    let pat   = get(ref,'pat','')
    let files = get(ref,'files',[])
    let opt   = get(ref,'opt',opt)

    let rootdir = get(ref,'rootdir','')

    if strlen(rootdir)
        call map(files,'base#file#catfile([ rootdir, v:val ])')
    endif

    if opt == 'plg_findstr'

        let gref = {
            \  "files"       : files          ,
            \  "pat"         : pat            ,
            \  "cmd_name"    : 'Rfindpattern' ,
            \  "findstr_opt" : '/i'           ,
            \  "cmd_opt"     : '/R /S'        ,
            \  "use_startdir"  : 0            ,
            \}

        let cmd = 'call findstr#ap#run(gref)'

    elseif opt == 'vimgrep'
        let cmd = 'vimgrep /'.pat.'/ '. join(files,' ') 
    endif

    exe cmd
    
endfunction

function! base#grepopt (...)
    if ! base#varexists('grepopt')
        if has('win32')
            let opt = 'plg_findstr'
        else
            let opt = 'grep'
        endif
    else
        let opt = base#var('grepopt')
    endif

    if a:0 | let opt = a:1 | endif
    call base#var('grepopt',opt)

    return base#var('grepopt')
endfunction

function! base#envvarlist ()
    call base#envvars()
    let evlist = base#var('evlist')

    return evlist

endfunction

function! base#envvars ()

     if has('win32')
         call base#sys({ "cmds" : [ 'env' ]})
         let sysout = base#var('sysout')
    
         let ev={}
         let pats = {
            \ 'ev' : '\(\w\+\)=\(.*\)$',
            \ }
         for l in sysout
            if l =~ pats.ev
                let vname = substitute(l,pats.ev,'\1','g')
                let val   = substitute(l,pats.ev,'\2','g')
                call extend(ev,{ vname : val })
            endif
         endfor
     endif

     let evlist = sort(keys(ev))
     call base#var('ev',ev)
     call base#var('evlist',evlist)

     return ev

endfunction

function! base#keymap (...)

    if a:0
        let keymap=a:1
    else 
        return
    endif

    exe 'setlocal keymap=' . keymap

    redraw!
    echohl MoreMsg
    echo "Keymap reset (locally) in buffer to : " . keymap
    echohl None

endfunction

function! base#equalpaths (p1,p2)

 let sep='/'

 let a1=filter(split(a:p1,sep),"v:val != ''")
 let a2=filter(split(a:p2,sep),"v:val != ''")

 if len(a1) != len(a2)
     return 0
 endif

 while len(a1) > 0

    let e1=remove(a1,-1)
    let e2=remove(a2,-1)

    if e1 != e2 
      return 0
    endif
 endw
 return 1
 
endfunction
 


