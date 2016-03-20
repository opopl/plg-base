
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

"
"function! base#varupdate (varname)

  "call ap#Vars#set(a:varname)
  
"endfunction
 
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

fun! base#opttrue(opt)
  let opt=a:opt

  if !exists("g:opts")
    let g:opts={}
  endif

  if has_key(g:opts,opt) 
    if g:opts[opt] 
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

function! base#cd(dir)
	exe 'cd ' . a:dir
	echohl MoreMsg
	echo 'Changed to: ' . a:dir
	echohl None
endf

function! base#CD(dirid)

	let dir = base#path(a:dirid)
	if isdirectory(dir)
		call ap#cd(dir)
	else
		call base#warn({ "text" : "Is NOT a directory: " . dir })
	endif

endf


"""base_catpath
fun! base#catpath(key,file,...)
 
 if !exists("s:paths")
    call base#initpaths()
 endif

 if has_key(s:paths,a:key)
    let fpath=base#file#catfile([ s:paths[a:key], a:file ])
 elseif a:key == '~'
    let fpath=base#file#catfile('~', a:file)
 else
    let fpath=a:file
 endif

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
			\	"text" : 'Settings "files" hash anew...',
			\	})
    	let s:files={}
	endif

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
			\	"text" : 'Settings paths anew...' 
			\	});
    	let s:paths={}
	endif

	let confdir   = base#envvar('CONFDIR')
	let vrt       = base#envvar('VIMRUNTIME')
	let hm        = base#envvar('hm')
	let mrc       = base#envvar('MYVIMRC')
	let projsdir  = base#envvar('PROJSDIR')

	call base#pathset({ 
		\ 'conf' : confdir ,
		\ 'vrt'  : vrt,
		\ 'vim'  : base#envvar('VIM'),
		\	})

	let mkvimrc  = base#file#catfile([ base#path('conf'), 'mk', 'vimrc' ])
	let mkbashrc = base#file#catfile([ base#path('conf'), 'mk', 'bashrc' ])

	call base#pathset({
		\	'mkvimrc'     : mkvimrc,
		\	'pdfout'      : base#envvar('PDFOUT'),
		\	'mkbashrc'    : mkbashrc,
		\	'coms'        : base#file#catfile([ mkvimrc, '_coms_' ]) ,
		\	'funs'        : base#file#catfile([ mkvimrc, '_fun_' ]) ,
		\	'projs'       : projsdir,
		\	'perlmod'     : base#file#catfile([ hm, base#qw("repos git perlmod") ]),
		\	'perlscripts' : base#file#catfile([ hm, base#qw("scripts perl") ]),
		\	'scripts'     : base#file#catfile([ hm, base#qw("scripts") ]),
		\	})

	"" remove / from the end of the directory
    for k in keys(s:paths)
       let s:paths[k]=substitute(s:paths[k],'\/\s*$','','g')
    endfor

	if exists("g:dirs")
	   call extend(s:paths,g:dirs)
	endif
	let g:dirs = s:paths

    let pathlist= sort(keys(s:paths))
	call base#var('pathlist',pathlist)

	call base#echoprefixold()
endf
 
"""base_fileopen
fun! base#fileopen(ref)
 let files=[]

 if base#type(a:ref) == 'String'
   let files=[ a:ref ] 
   
 elseif base#type(a:ref) == 'List'
   let files=a:ref  
   
 elseif base#type(a:ref) == 'Dictionary'
   let files=a:ref.files  
   
 endif

 let action = 'edit'
 let a      = base#var('fileopen_action')
 if strlen(a) | let action = a | endif

 for file in files
    exe action . ' ' . file
 endfor
 
endfun
 

"""base_inlist
fun! base#inlist(element,list)
 let r=( index(a:list,a:element) >= 0 ) ? 1 : 0

 return r 

endfun

"""base_getfromchoosedialog
function! base#getfromchoosedialog (opts)

  if base#type(a:opts) != 'Dictionary'
    call base#warn({ 
		\	"text" : "wrong type of input argument 'opts' - should be Dictionary"
		\	})

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
		\	"text" : "input list of options was not provided"
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
	  let file = base#varhash#get('datfiles',a:ref)
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

"""base_varupdate
function! base#varupdate(ref)

 LFUN VH_linesTOC

 """ used for : DC_Proj_SecNames 
 LFUN DC_Proj_GenSecDat

 if type(a:ref) == type('')
   let varname=a:ref
   
 elseif type(a:ref) == type([])
   let vars=a:ref
   for varname in vars
     call base#varupdate(varname)
   endfor

   return
   
 endif

 let varname=substitute(varname,'^\(g:\)\+','','g')

 if exists(varname) 
   exe 'unlet g:' . varname
 endif

"""PAP_texpkeys
     if varname == 'PAP_texpkeys'
        let g:PAP_texpkeys=base#readdatfile('list_tex_papers')

   elseif varname == 'PAP_LOF_files'

        let g:{varname} = base#fnamemodifysplitglob('p','*.lof',':p:t:r')

     elseif varname == 'PAP_bibfiles'

      	let g:{varname}={
              \ 'repdoc'  : base#catpath('p','repdoc.bib'),
              \ 'wchfdoc' : base#catpath('cit','wchfdoc.bib'),
            \}

"""PAP_bibkeys
     elseif varname == 'PAP_bibkeys'
        let g:PAP_bibkeys=base#readdatfile('list_bibkeys')

     elseif varname == 'TXT_InsertCmds'

        let g:{varname}={}
        for ft in [ 'vim', 'perl', 'tex', 'html' ]
            let g:{varname}[ft]=base#readdatfile(varname . '_' . ft)
        endfor

"""varupdate_pkey
     elseif varname == 'pkey'

       if !exists('g:' . varname)
            let g:{varname}=input('Paper name:','',
                \   'custom,PAP_CompleteTexPapers')
            call base#echoredraw('Paper key set: ' . g:pkey )
       endif


"""varupdate_files
     elseif varname == 'files'
        RFUN F_SetFiles

"""varupdate_paths
     elseif base#inlist(varname, [ 'paths', 'paths_list' ])
        call base#initpaths() 

     elseif varname == 'modelines'
        call base#varreset(varname,base#readdictDat(varname))

     elseif varname == 'TEX_StyFiles'

         let g:{varname}={
            \ 'my.sty': 'p',
            \}

     elseif varname == 'TEX_TexDefsAdded'

       let g:{varname}=[
          \ 'pmyyq',
          \ ]

"""VimSnips
     elseif varname == 'VimSnips'
       let g:{varname}=base#findunix({ 
            \   'path'          : 'vimsnips',
            \   'ext'           : 'vim',
            \   'fnamemodify'   : ':p:t:r',
            \   })


"""pdf_perldoc
     elseif varname == 'pdf_perldoc'
       let g:{varname}=base#findunix({
                \   'dir'           : s:paths['pdfout'] . '/perldoc',
                \   'ext'           : 'pdf',
                \   'fnamemodify'   : ':p:t:r',
                \   })

"""F_Bushes
     elseif varname == 'F_Bushes'
        let g:F_Bushes=[]

        call extend(g:F_Bushes,base#fnamemodifysplitglob('mkbashrc','*.bash',':t'))
        call extend(g:F_Bushes,base#fnamemodifysplitglob('mkbashrc','*.sh',':t'))

     elseif varname == 'SIMPLE_MakeSteps'

    let g:{varname}=[
          \  'tex_run' ,
          \  'tex_generate',
          \ ]

  elseif varname == 'LASU_IgnoreUnmatched'
      let g:{varname}= 1

  elseif varname == 'LASU_ShowallLines'
      let g:{varname}= 0

    elseif varname == 'rootlatexfile'
        let g:{varname}=''
        if &ft == 'tex'
              let g:{varname}= expand('%:p')
        endif

      elseif varname == 'roottexfile'
        let g:{varname}=''
        if &ft == 'plaintex'
          let g:{varname}= expand('%:p')
        endif

    elseif varname == 'PAP_DocStyles'

    let fcmd="find " 
      \ . base#catpath('p','docstyles') 
      \ . " -mindepth 1 -type d | perl -n -MFile::Basename -e 'print basename(\$_)'"

    let g:{varname}=split(system(fcmd),"\n")

    elseif varname == 'PAP_pkey'

    call base#varcheckexist([ 'RE' ])
 
      " g:PAP_pkey  - paper key, e.g. HT92
       let g:{varname}=substitute(g:PAP_papername,g:RE['PAP_paperpat'],'\1',"g")

    elseif varname == 'PAP_psec'

    call base#varcheckexist([ 'RE' ])

    " g:PAP_psec  - name of tex piece e.g. figs
    let g:{varname}=substitute(g:PAP_papername,g:RE['PAP_paperpat'],'\2',"g")
    let g:{varname}=substitute(g:{varname},'\.$','',"g")

    elseif varname == 'PAP_CurrentSection'

    call base#varupdate([ 'PAP_psec' ])

      let g:{varname}=substitute(g:PAP_psec,'^sec\.\(.*\)\.i','\1','g')

    elseif varname == 'PAP_listvars'

        LCOM CD
      
      CD p

      if ( !exists("g:PAP_listvars") || exists("g:PAP_FlagSetupRedo") )
        let g:PAP_listvars=split(system(  "mktex.pl --listvars | sort " ),"\n") 
    
        for var in g:PAP_listvars 
          let value=system(  "mktex.pl --var " . var )
          let value=substitute(value,"\n",'','')
          exe 'let g:PAP_' . var . '=' . "'" . value . "'"
        endfor
      endif

    elseif varname == 'PAP_PdfGen'
      let g:{varname}=base#findunix({ 
            \   'dir' : s:paths['p'] . '/out',
            \   'ext' : 'pdf',
            \   'relpath' : 1,
            \   'fnamemodify' : ':p:r',
            \   })

    elseif varname == 'PAP_PdfPapers'

        call base#mapsub()
        call base#basenamesplitglob()

      let g:PAP_PdfPapers=base#mapsub(base#basenamesplitglob('pdfpaps','*.pdf'),'\.pdf$','','g')

    elseif varname == 'DC_Proj_Files'

     let g:{varname} = base#splitglob('projs',g:proj . ".*.tex")
    
     call add(g:{varname},base#catpath('projs', g:proj . '.tex'))

"""comment_char
     elseif varname == 'comment_char'
             call base#varupdate('comment_chars')

             let g:{varname}= index(keys(g:comment_chars),&ft) < 0 ? '#' : 
                        \   g:comment_chars[&ft]

     elseif varname == 'comment_chars'
             let g:{varname}={
                    \   'tex' : '%',
                    \   'perl' : '#',
                    \   'vim' : '"',
                    \   }

"""varupdate_DC_Proj_Name
     elseif varname == 'DC_Proj_Name'
       call base#varcheckexist('proj')

       let g:{varname}=g:proj

     elseif varname == 'DC_PrjTexOutDir'
       "let g:{varname}=$hm . '/texbuilds/projs/'
       call base#varcheckexist('paths')
       let g:{varname}=s:paths['projs']

     elseif varname == 'DC_PrjTexMode'
       let g:{varname}='nonstopmode'

"""proj
     elseif varname == 'proj'
       LFUN DC_CompleteProjs

       let g:proj=input('Select project:','','custom,DC_CompleteProjs')

"""DC_Proj_SecNamesBase
     elseif varname == 'DC_Proj_SecNamesBase'
        call base#setglobalvarfromdat(varname)

"""DC_Proj_SecNames
     elseif varname == 'DC_Proj_SecNames'
       call base#varcheckexist([ 
              \ 'DC_Proj_SecNamesBase',
              \ 'DC_Proj_SecDatFile',
              \  ])

       let g:{varname}=base#rmendssplitglob('texdocs',g:proj . ".*.tex")

       call filter(g:{varname},"! base#inlist(v:val,g:DC_Proj_SecNamesBase)")

       call writefile(g:DC_Proj_SecNames,g:DC_Proj_SecDatFile)

       call base#uniq(varname)

     elseif varname == 'DC_Proj_SecDatFile'
       let g:{varname}=base#catpath('projs',g:proj . '.secs.i.dat')

     elseif varname == 'DC_Proj_SecOrderFile'
       let g:{varname}=base#catpath('projs',g:proj . '.secorder.i.dat')

       "call DC_Proj_GenSecDat()
       "
     elseif varname == 'OMNI_COMP_ARRAYS'
        let g:{varname}=base#readdictDat('OMNI_COMP_ARRAYS')

     elseif varname == 'OMNI_CompOptions_List'
        call base#varupdate('OMNI_COMP_ARRAYS')

    let comps=[]
    
    call extend(comps,keys(g:OMNI_COMP_ARRAYS))
    call add(comps,'_smart_tex')
    
    let g:OMNI_CompOptions_List=sort(comps)

"""PAP_allowed_psecs
     elseif varname == 'PAP_allowed_psecs'
        call base#setglobalvarfromdat(varname)

     elseif varname == 'IMOD_opts'
       LFUN F_opts_to_str

      " Install selected module
        let g:{varname}=F_opts_to_str({
          \ 'rbi_force'             : 1,
          \ 'rbi_discard_loaddat'   : 1,
          \} )

     elseif varname == 'IMODS_opts'
       LFUN F_opts_to_str

        let g:{varname}=F_opts_to_str({
          \ 'rbi_force'             : 1,
          \ 'rbi_discard_loaddat'   : 1,
          \ 'selectdialog'          : 1,
          \} )

"""perl_local_modules
     elseif varname == 'perl_local_modules'
        "let g:perl_local_modules=base#readdatfile('modules_all')

                let cmd='pmi --searchdirs ' . $PERLMODDIR . '/lib --print names ^'
            let g:{varname} = base#splitsystem( cmd )

"""perl_used_modules
     elseif varname == 'perl_used_modules'
        call base#setglobalvarfromdat('perl_used_modules',{
            \       'type'              : 'List', 
            \       'splitlines'        : 1,
            \       'select_fields'     : '0',
            \   })

        let g:perl_used_modules_paths=base#readdictdat('perl_used_modules')

"""perl_installed_modules
     elseif varname == 'perl_installed_modules'
        call base#datupdate('perl_installed_modules')

        call base#setglobalvarfromdat('perl_installed_modules',{
            \       'type'              : 'List', 
            \       'splitlines'        : 1,
            \       'select_fields'     : '0',
            \   })

        let g:perl_installed_modules_paths=base#readdictDat('perl_installed_modules')

     elseif varname == 'PMOD_perltopics'
         let g:PMOD_perltopics=base#readdatfile('PerlTopics')
        
         for id in base#qw("statements AUTOLOAD _DATA__ attributes ")
              call extend(g:PMOD_perltopics,base#readdatfile('PerlTopics_' . id ))
         endfor

     elseif base#inlist(varname,[ 
            \   'path', 
            \   'filename_root', 
            \   'filename',
            \   'fileinfo',
            \   'dirname',
            \   'ext',
            \   ])

        call base#getfileinfo()

     elseif varname == 'PMOD_ModuleName'

        LFUN F_sss
        call base#varupdate('path')

        if &ft == 'perl'
            let g:{varname}=F_sss('get_perl_package_name.pl --ifile ' . g:path )
        else
            let g:{varname}=''
        endif

     elseif varname == 'APACHE_Files'
        let g:{varname}=base#readdictDat(varname)

        call base#varupdate('APACHE_FilesList')

     elseif varname == 'APACHE_FilesList'
        call base#varcheckexist('APACHE_Files')

        let g:{varname}=sort(keys(g:APACHE_Files))

     elseif varname == 'vim_funcs_user'
		call base#var(varname,
			\	base#fnamemodifysplitglob('funs','*.vim',':t:r')
			\	)

     elseif varname == 'vim_coms'
        let g:vim_coms=base#fnamemodifysplitglob('vimcom','*.vim',':t:r')

     elseif varname == 'DC_ProjsDir'
        let g:DC_ProjsDir=s:paths['projs']

     elseif varname == 'DC_ProjsFile'
        let g:DC_ProjsFile=base#catpath('projs','PROJS.i.dat')

     elseif varname == 'DC_MkProjsFile'
        let g:DC_MkProjsFile=base#catpath('projs','MKPROJS.i.dat')

     elseif varname == 'projs'
        let g:projs=base#readdatfile('PROJS')

     elseif varname == 'mkprojs'
        let g:mkprojs=base#readdatfile('MKPROJS')

     elseif varname == 'DC_List_Pdf_Projs'
        let g:DC_List_Pdf_Projs=base#fnamemodifysplitglob('pdfout','*.pdf',':t:r')
        "
        " calculate intersection of arrays 
        "   g:DC_List_Pdf_Projs and g:projs
        "
        let projs=[]
      
        for proj in g:DC_List_Pdf_Projs
          if index(g:projs,proj) >=0
            call add(projs,proj)
          endif
        endfor
      
        let g:DC_List_Pdf_Projs=projs

"""DC_FilledProjs
     elseif varname == 'DC_FilledProjs'
          let g:DC_FilledProjs=[
            \ 'Metcalf_Fortran90_Explained',
            \ 'apsc',
            \ 'Dict',
            \ ]

"""DC_VimHelpFiles
     elseif varname == 'F_VimHelpFiles'
          call base#varreset( varname ,{})
          for path in split(globpath(&rtp, 'doc/*.txt' ),"\n")
            let vh=fnamemodify(path,':t:r')
            let g:{varname}[vh]=path
          endfor

"""DC_pdf_docs
     elseif varname == 'DC_pdf_docs'

            call base#varreset(varname,{})

"""_pdf_docs
            if exists("s:paths.pdfdocs")
                
                let dir=s:paths['pdfdocs']
                let docs={}

                if len(dir) 
    
                    let docs[dir]=base#fnamemodifysplitglob('pdfdocs','*.pdf',':p:t:r')
        
                    let docs[dir]=base#findunix({  'path'              : 'pdfdocs', 
                              \       'relpath'           : 1, 
                              \       'ext'               : 'pdf',
                              \       'fnamemodify'       : ':r',
                              \       })
        
                    let edocs={
                          \   '~/wrk/ap/oia/myR/' : [
                              \ 'OP_to_OIA_confirmation_letter', 
                              \ 'OP_to_OIA_further_remarks',
                                \   ],
                          \    '~/doc/fortran/' : [
                                \   'Metcalf-Fortran90-Explained',
                                \   ],
                          \    '~/wrk/ap/oia/myR': [ 'R1', 'R2', 'R3' ],
                          \    '~/wrk/ap/oia/UC/': map(base#listnewinc(0,30,1),"'UC-' . v:val")
                          \ }
        
                    call extend(docs,edocs)
        
                    for dir in keys(docs)
                      for docid in docs[dir]
                        let docpath=dir . '/' . docid . '.pdf'
                        call extend(g:{varname},{ docid : docpath })
                      endfor
                    endfor

                endif

            endif

"""varupdate_opts
     elseif varname == 'opts'

          call base#setglobalvarfromdat('opts',{ 'type' : 'Dictionary' })

    elseif varname == 'pathsep'

        let g:{varname}= '/'
         if has('win32')
            let g:{varname}= '\'
         endif

"""varupdate_datfiles
    elseif varname == 'datfiles'
        
        call base#varcheckexist([ 'paths', 'pathsep' ])

		let s:datfiles={}
		let file = base#catpath('mkvimrc','datfiles.i.dat') 

        let s:datfiles = base#readdatpaths({ 
            \ 'rootdir'   : base#path('mkvimrc'),
            \ 'file'      : file,
            \ 'ext'       : '.i.dat',
            \ })


"""datfiles_pp
      let vars=[
        \ 'vars_goossens',
        \ 'vars_htlatex',                        
        \ 'vars',                                
        \ ]

      for id in vars
        let s:datfiles['pp_' . id]=base#catpath('p',id . '.i.dat')
      endfor

	  call base#var('datfiles_mkvimrc',s:datfiles)
	  call base#var('datlist_mkvimrc',base#varhash#keys('datfiles_mkvimrc'))

"""varupdate_allmenus
      elseif varname == 'allmenus'
          LCOM PrjMake

          let g:{varname}={}

          for i in base#listnewinc(1,10,1)
            let g:{varname}[ 'ToolBar.sep' . i ]=  {
                  \ 'item'    : '-sep' . i .'-',  
                  \ 'fullcmd' : 'an ToolBar.-sep' . i . '- <Nop>',  
                  \ }
          endfor

          let menus={
            \ 'ToolBar.PlainTexRun' : {
                  \ 'icon' : 'PlainTexRun', 
                  \ 'item' : 'ToolBar.PlainTexRun', 
                  \ 'cmd'  : 'PlainTexRun', 
                  \ 'tmenu': 'PlainTexRun' },
            \ 'ToolBar.MAKE' : {
                  \ 'icon' : 'MAKE', 
                  \ 'item' : 'ToolBar.MAKE',  
                  \ 'cmd'  : 'PrjMake', 
                  \ 'tmenu': 'MAKE' },
            \ 'ToolBar.VIEWPDF' : {
                  \ 'icon' : 'VIEWPDF', 
                  \ 'item' : 'ToolBar.VIEWPDF', 
                  \ 'cmd'  : 'call DC_PrjView("pdf")', 
                  \ 'tmenu': 'View PDF' },
            \ 'ToolBar.VIEWLOG' : {
                  \ 'icon' : 'VIEWLOG',   
                  \ 'item' : 'ToolBar.VIEWLOG', 
                  \ 'cmd'  : 'call DC_PrjView("log")', 
                  \ 'tmenu': 'View TeX Log File' },
            \ 'ToolBar.MAIN' : {
                  \ 'icon' : 'MAIN', 
                  \ 'item' : 'ToolBar.MAIN',  
                  \ 'cmd'  : 'VSECBASE _main_', 
                  \ 'tmenu': 'Open root project file' },
            \ 'ToolBar.BODY' : {
                  \ 'icon' : 'BODY', 
                  \ 'item' : 'ToolBar.BODY',  
                  \ 'cmd'  : 'VSECBASE body', 
                  \ 'tmenu': 'Open body TeX file' },
            \ 'ToolBar.PREAMBLE' : {
                  \ 'icon' : 'PREAMBLE', 
                  \ 'item' : 'ToolBar.PREAMBLE',  
                  \ 'cmd'  : 'VSECBASE preamble', 
                  \ 'tmenu': 'Open preamble TeX file' },
            \ 'ToolBar.PACKAGES' : {
                  \ 'icon' : 'PACKAGES', 
                  \ 'item' : 'ToolBar.PACKAGES',  
                  \ 'cmd'  : 'VSECBASE packages',
                  \ 'tmenu': 'Open TeX file with packages' ,
                  \ },
            \ 'ToolBar.DEFS' : {
                  \ 'icon' : 'DEFS', 
                  \ 'item' : 'ToolBar.DEFS',  
                  \ 'cmd'  : 'VSECBASE defs',
                  \ 'tmenu': 'Open TeX file with definitions' ,
                  \ },
            \ 'ToolBar.HTLATEX' : {
                  \ 'icon' : 'HTLATEX', 
                  \ 'item' : 'ToolBar.HTLATEX', 
                  \ 'cmd'  : 'PrjMakeHTLATEX',
                  \ 'tmenu': 'Run TeX4HT using HTLATEX' ,
                  \ },
            \ 'ToolBar.VIEWHTML' : {
                  \ 'icon' : 'VIEWHTML', 
                  \ 'item' : 'ToolBar.VIEWHTML',  
                  \ 'cmd'  : 'PrjViewHtml',
                  \ 'tmenu': 'View generated HTML' ,
                  \ },
            \ 'TOOLS.VIEWPDF' : {
                  \ 'item' : '&TOOLS.&VIEWPDF', 
                  \ 'tab' : 'View\ compiled\ PDF',  
                  \ 'cmd' : 'call DC_PrjView("pdf")', 
                  \ },
            \ 'TOOLS.VIEWLOG' : {
                  \ 'item' : '&TOOLS.&VIEWLOG', 
                  \ 'tab' : 'View\ TeX\ Log\ file', 
                  \ 'cmd' : 'call DC_PrjView("log")', 
                  \ },
            \ 'TOOLS.VIEW.idx' : {
                  \ 'item' : '&TOOLS.&VIEW.&idx', 
                  \ 'tab' : 'View\ idx',  
                  \ 'cmd' : 'call DC_PrjView("idx")', 
                  \ },
            \ 'TOOLS.VIEW.ind' : {
                  \ 'item' : '&TOOLS.&VIEW.&ind', 
                  \ 'tab' : 'View\ ind',  
                  \ 'cmd' : 'call DC_PrjView("ind")', 
                  \ },
            \ 'TOOLS.VIEW.aux' : {
                  \ 'item' : '&TOOLS.&VIEW.&aux', 
                  \ 'tab' : 'View\ aux',  
                  \ 'cmd' : 'call DC_PrjView("aux")', 
                  \ },
            \ 'TOOLS.VIEW.lof' : {
                  \ 'item' : '&TOOLS.&VIEW.&lof', 
                  \ 'tab' : 'View\ lof',  
                  \ 'cmd' : 'call DC_PrjView("lof")', 
                  \ },
            \ 'TOOLS.VIEW.lot' : {
                  \ 'item' : '&TOOLS.&VIEW.&lot', 
                  \ 'tab' : 'View\ lot',  
                  \ 'cmd' : 'call DC_PrjView("lot")', 
                  \ },
            \ 'TOOLS.RWPACK' : {
                  \ 'item' : '&TOOLS.&RWPACK',  
                  \ 'tab' : 'Rewrite\ packages',  
                  \ 'cmd' : 'call DC_PrjRewritePackages()', 
                  \ },
            \ }

          call extend(g:{varname},menus)

"""allmenus_PERL
          LFUN Prl_module_subs

          let menus={
            \ 'PERL.module_subs' : {
                  \ 'item' : '&PERL.&module_subs',  
                  \ 'tab' : 'List\ subroutines',  
                  \ 'cmd' : 'echo Prl_module_subs()', 
                \   },
            \   }

          call extend(g:{varname},menus)

          call base#varcheckexist('OMNI_CompOptions_List')
          let omnitopics={
                \ 'PERL' : [
                      \ 'perl_used_modules', 
                      \ 'perl_local_modules', 
                      \ 'perl_installed_modules',
                      \ 'perl_subs_traveltek',
                      \ 'perl_module_subs',
                      \ ],
                \ 'TEX' : [
                      \ '_smart_tex',
                      \ 'TEXHT_CfgNames',
                      \ 'tex_TEXHT_commands',
                      \ 'tex_latex_commands_graphics',
                      \ 'tex_latex_commands_text',
                      \ 'tex_latex_environments',
                      \ 'tex_latex_packages',
                      \ 'tex_latex_pagestyles',
                      \ 'tex_plaintex_commands',
                      \ ],
                \ 'PROJS' : [
                      \ 'proj_defs',
                      \ 'proj_secs',
                      \ 'projs',
                      \ ],
                \ 'PAPS' : [
                      \ 'pap_isecs',
                      \ 'pap_pdf_papers',
                      \ 'pap_tex_papers',
                      \ 'bibkeys',
                      \ ],
                \ 'TAGS' : [
                      \ 'ctags_tagids',
                      \ ],
                \ 'VIM' : [
                      \ 'vimperlfuncs',
                      \ 'vim_commands_user',
                      \ 'vim_funcs_core',
                      \ 'vim_funcs_user',
                      \ ],
                \ 'OTHER' : [
                      \ 'snippets',
                      \ ],
                \ }

          let g:menus_omni={}
          for omni in g:OMNI_CompOptions_List
              let omnitopic=''
              let item='OMNI.' . omni

              for [topic,opts] in items(omnitopics)
                if base#inlist(omni,opts)
                  let omnitopic='&' . topic . '.'
                endif
              endfor

              let menuitem={
                  \ 'item' : '&OMNI.' . omnitopic . '&' . omni,
                  \ 'cmd'  : 'OMNIFUNC ' . omni,
                  \ }
              let g:{varname}[item]=menuitem
              call extend(g:menus_omni,{ item : menuitem })

          endfor

"""TXT
     elseif varname == 'TXT_venclose_structnames'
       RFUN TXT_Setup

"""TEXHT
     elseif varname == 'TEXHT_CfgNames'
       let g:{varname}=[]

       call base#varcheckexist('texinputs')

       for dir in g:texinputs
          let files=base#findunix({
                \ 'dir'           : dir,
                \ 'ext'           : 'tex',
                \ 'startpattern'  : '_cfg.',
                \ 'fnamemodify'   : ':p:t',
                \})

          call map(files,"matchstr(v:val,'" . '^_cfg\.\zs.*\ze\.tex$' . "')" )
          call extend(g:{varname},files)
       endfor

"""varupdate_texinputs
     elseif varname == 'texinputs'
       let g:{varname}=[]
       if exists("$TEXINPUTS")
          let g:{varname}=base#uniq(split($TEXINPUTS,':'))
       endif

"""TEX
     elseif varname == 'TEX_PlainTexMacros'
       let g:{varname}=sort(base#findunix({
        \ 'dir' : s:paths['tex'] . '/texmf-dist/tex/plain',
        \ 'ext' : 'tex',
        \ 'relpath' : 1,
        \}))

     elseif varname == 'TEXHT_Files'
       let g:{varname}=[]
     
     let dirs=[
        \ 'tex/generic/tex4ht',
        \ 'tex4ht',
        \ ]

     for dir in dirs
       let files=sort(base#findunix({
          \ 'dir' : g:texlive['TEXMFDIST'] . '/' . dir,
          \ 'ext' : 'tex,env,4ht',
          \} ))
       
       call map(files,"matchstr(v:val,'^' . g:texlive['TEXMFDIST'] . '/\\zs.*\\ze$' )")

       call extend(g:{varname},files)
     endfor

     elseif varname == 'TEX_PlainTexExamples'
       let g:{varname}=sort(base#findunix({
        \ 'dir' : s:paths['tex'] . '/texmf-dist/doc/plain',
        \ 'ext' : 'tex',
        \ 'relpath' : 1,
        \}))

     elseif varname == 'texlive'
       LFUN TEX_kpsewhich

       let g:{varname}={
             \  'TEXMFDIST'  : TEX_kpsewhich('--var-value=TEXMFDIST'),
             \  'TEXMFLOCAL' : TEX_kpsewhich('--var-value=TEXMFLOCAL'),
             \  }

     elseif varname == 'TEX_TexCmds'
       let g:{varname}=sort(base#fnamemodifysplitglob('p',"texcmd.*.tex",':r:e'))

     elseif varname == 'TEX_TexDefs'
       let g:{varname}=sort(base#fnamemodifysplitglob('p',"def.*.tex",':r:e'))

     elseif base#inlist(varname, [
          \ 'TEX_InsertEntries',
          \ 'TEX_TexDocEntries',
          \ 'TEX_latex_environments',
          \ 'TEX_latex_commands_text',    
          \ 'TEX_latex_commands_graphics',
          \ ])

       let g:{varname}=base#readdatfile(varname)

"""TEX_TexPackages
     elseif varname == 'TEX_TexPackages'

       call base#varcheckexist('TEX_LatexPackages')
       let g:{varname}=base#readdatfile(varname)

       "call filter(g:{varname},'base#inlist(v:val,g:TEX_LatexPackages)')

     elseif varname == 'TEX_TexTopics'
       let g:{varname}=sort(base#fnamemodifysplitglob('p',"htex.*.tex",':r:e'))

     elseif varname == 'TEX_LatexPackages'
       let g:{varname}=base#findunix({ 
            \   'dir'           : g:texlive['TEXMFDIST'] . '/tex/latex/', 
            \   'type'          : 'd', 
            \   'maxdepth'      : 1, 
            \   'fnamemodify'   : ':t',
            \   } )


     elseif varname == 'DC_Proj_SecOrderFile'
        let g:{varname}=base#catpath('texdocs', g:proj . '.secorder.i.dat' )

"""VVP_all_vimrcpieces
     elseif varname == 'VVP_all_vimrcpieces'
        let g:VVP_all_vimrcpieces=base#fnamemodifysplitglob('mkvimrc','*.vim',':t')

     elseif varname == 'TXT_used_keymaps'
        let g:TXT_used_keymaps=base#readdatfile('used_keymaps')

     elseif varname == 'DC_Proj_usedpacks' || varname == 'DC_Proj_packopts'
        RFUN DC_Proj_GetPackages

   elseif varname == 'LASU_IgnoredWarnings'
      let g:{varname} =join(base#readdatfile(varname,{ 'splitlines' : '0' }),"\n")

   elseif varname == 'LASU_IgnoreLevel'

     call base#varcheckexist('LASU_IgnoredWarnings')

     let g:{varname}=len(g:LASU_IgnoredWarnings)

"""LASU_FoldedMisc
   elseif varname == 'LASU_FoldedMisc'

          " Folding items which are not caught in any of the standard commands,
          " environments or sections.
          let s =  join(base#readdatfile('LASU_FoldedMisc'),",")
          if !exists('g:LASU_FoldedMisc')
            let g:LASU_FoldedMisc = s
          elseif g:LASU_FoldedMisc[0] == ','
            let g:LASU_FoldedMisc = s . g:LASU_FoldedMisc
          elseif g:LASU_FoldedMisc =~ ',$'
            let g:LASU_FoldedMisc = g:LASU_FoldedMisc . s
          endif

"""LASU_FoldedCommands
   elseif varname == 'LASU_FoldedCommands'

      let s=''
          if !exists('g:LASU_FoldedCommands')
            let g:LASU_FoldedCommands = s
          elseif g:LASU_FoldedCommands[0] == ','
            let g:LASU_FoldedCommands = s . g:LASU_FoldedCommands
          elseif g:LASU_FoldedCommands =~ ',$'
            let g:LASU_FoldedCommands = g:LASU_FoldedCommands . s
          endif

"""LASU_FoldedEnvironments
   elseif varname == 'LASU_FoldedEnvironments'
          let s =  join(base#readdatfile('LASU_FoldedEnvironments'),",")
                        
          if !exists('g:LASU_FoldedEnvironments')
                let g:LASU_FoldedEnvironments = s
          elseif g:LASU_FoldedEnvironments[0] == ','
                let g:LASU_FoldedEnvironments = s . g:LASU_FoldedEnvironments 
          elseif g:LASU_FoldedEnvironments =~ ',$'
                let g:LASU_FoldedEnvironments = g:LASU_FoldedEnvironments . s
          endif

"""LASU_FoldedSections
   elseif base#inlist(varname,[ 'LASU_FoldedSections' ]) 
         exe 'let g:' . varname . "= join(base#readdatfile(varname),',')" 

"""LASU_FoldedSectionEnds
   elseif base#inlist(varname,[ 'LASU_FoldedSectionEnds' ]) 
         exe 'let g:' . varname . '= base#readdatfile(varname)' 

"""perl_loaded_modules
   elseif varname == 'perl_loaded_modules'
        let g:perl_loaded_modules_paths={}
        let g:perl_loaded_modules=[]

"""DICT_dicts
   elseif varname == 'DICT_dicts'

         let g:DICT_dicts={}
        
         let lines=base#readdatfile('DICT_dicts', { 'splitlines': 0} )
         for line in lines
           let vars=split(line,'\s\+')
        
           let dictkey=remove(vars,0)
           let dirkey=remove(vars,0)
           let fname=remove(vars,0)
        
           let dirkey=substitute(dirkey,'_\(\w\+\)_','\1','g')
        
           let dir=get(s:paths,dirkey)
        
           if isdirectory(dir)
            let filepath=dir . '/' . fname
            let g:DICT_dicts[dictkey]=filepath
           endif
         endfor
        
         let g:DICT_dict_list=sort(keys(g:DICT_dicts))

     elseif varname == 'CTAGS_CMD'
        
         let g:CTAGS_CMD={
                \ 'tex' : 'ctags -R ',
                \}

     elseif varname == 'VH_acts'
        call base#setglobalvarfromdat(varname)

     elseif varname == 'CTAGS_ListLangs'
         let g:CTAGS_ListLangs=base#splitsystem("ctags --list-languages")

     elseif varname == 'CTAGS_CtagsFiles'
         let g:CTAGS_CtagsFiles=base#fnamemodifysplitglob('tags','*.tags',':t:r')

     elseif varname == 'CTAGS_tagnames'

        """let_tagnames
        let g:CTAGS_tagnames={
            \ '_gops_B_ff_' : 'gops_B',
            \ '_mkvimrc_'   : 'mkvimrc',
            \ '_lasu_'      : 'lasu',
            \}

     elseif varname == 'INC'
        let g:INC=split(system("perl -e 'print join(\":\",@INC);'"),':')

     elseif varname == 'CTAGS_tagdirs'
         let g:CTAGS_tagdirs={}
        
         let g:CTAGS_tagdirs={
                \ '_gops_B_ff_'   : s:paths['gops'] . '/B',
                \ '_mkvimrc_'     : s:paths['mkvimrc'],
                \ '_lasu_'        : s:paths['lasu'],
                \ '_proj_'        : s:paths['projs'],
                \ 'vh_perldoc'    : s:paths['plugins'] . '/perldoc/doc',
                \}
        
         for id in base#qw(" _paptex_  repdoc_bib psh_pl ")
            let g:CTAGS_tagdirs[id]=s:paths['p']
         endfor

     
     elseif varname == 'tagfile'
       let g:tagfile=''

     elseif varname == 'tagfiles'
       let g:tagfiles=[]

     elseif varname == 'F_tex_omnifuncs'

        let g:F_tex_omnifuncs=[
          \ 'tex_math',
          \ 'tex_plaintex',
          \ ]

"""RE
     elseif varname == 'RE'
        let g:{varname}=base#readdictDat(varname)

"""varupdate_plugins
    elseif base#inlist(varname, [
          \ 'plugins',
          \ 'plugin_acts',
          \ ] )
      
        let g:{varname}=base#readdatfile(varname)


    elseif varname == 'allplugins'
        let g:{varname}=base#findunix( { 
            \   'dir'       : s:paths['plugins'], 
            \   'type'      : 'd'   ,
            \   'maxdepth'  : 1     ,
            \   'mindepth'  : 1     ,
            \   'sort'      : 1     ,
            \   'fnamemodify'  : ':p:h:t'     ,
            \   } )

"""varupdate_pluginfiles
     elseif varname == 'pluginfiles'

        call base#varcheckexist('plugins')

        if exists("g:plugin")

            let g:plugindir=base#catpath('plugins',g:plugin)

            let g:plugindirs=base#findunix({ 
                \   'dir'       : g:plugindir,
                \   'type'      : 'd',
                \   'maxdepth'  : 1,
                \   'mindepth'  : 1,
                \   'fnamemodify'  : ':t',
                \   } )

            let g:{varname}=base#findunix({ 
                    \   'dir' : g:plugindir,
                    \   'ext' : 'vim',
                    \   })

            call map(g:{varname},"substitute(v:val,'^' . g:plugindir . '[/]*','','g')")

        else
            call base#subwarn('g:plugin variable is not set.')

        endif

     elseif varname == 'pluginroot'
        let g:pluginroot='_plugins'

     elseif varname == 'allplugins'

        call base#varupdate('pluginroot')
    
          let g:allplugins=base#fnamemodifysystem('find ' 
              \ . $VIMRUNTIME 
              \ . '/' . g:pluginroot . ' -maxdepth 1 -type d ',
              \ ':t:r'
              \ )

     elseif varname == 'VarUpdateOptions'
        let g:{varname}=base#readdatfile(varname)

"""vhook
     elseif varname == 'vhookTOC'
        call base#varreset('g:vhookTOC',[])
        call extend(g:vhookTOC,VH_linesTOC())

     elseif varname == 'vhookroot'
      LFUN VH_GetHooks
      LFUN VH_SetHooks

      call VH_GetHooks()
      call VH_SetHooks()

     elseif varname == 'SNI_available_snippet_extensions'
       let exts=[]
     call base#varcheckexist('SNI_snippetdirs')

       for snidir in g:SNI_snippetdirs
         call extend(exts, base#fnamemodifysystem('find ' . snidir . ' -name *.snippets',':t:r'))
       endfor

     call base#varreset(varname,sort(base#uniq(exts)))

     elseif varname == 'SNI_snippetdirs'
      call base#varcheckexist('rtp')
        let snidirs=base#readdatfile('snippetdirs')

    call base#varreset(varname,[])

    for snidir in snidirs
      for rtpdir in g:rtp
          let dir=rtpdir . '/' . snidir
        if isdirectory(dir)
          call add(g:SNI_snippetdirs,dir)
          endif
      endfor
    endfor

"""varupdate_ctagsexe
  elseif varname == 'ctagsexe'
        let g:{varname} = 'ctags'

"""varupdate_rtp
     elseif varname == 'rtp'
        let g:rtp=[ ]

        call base#varupdate('plugins')
        call base#varupdate('pluginroot')

        call add(g:rtp,$VIMRUNTIME)

        for plugin in g:plugins
           let pdir=$VIMRUNTIME . '/' .  g:pluginroot . '/' . plugin
           if isdirectory(pdir)
              call add(g:rtp,pdir)
           endif
        endfor

        call add(g:rtp,$VIMRUNTIME . '/after')

        let &rtp=join(g:rtp,',')

"""varupdate__dat__
     elseif base#inlist(varname,base#readdatfile('VarUpdateDat'))
           if base#inlist(varname,[
                 \   'TEX_plaintex_commands', 
                 \   'TEX_TEXHT_commands', 
                 \] )
              let g:{varname}=base#readdatfile(varname,{ 'splitlines' : 0 })

           elseif  varname == 'PAP_parts'
          let g:{varname}=
            \ base#readdatfile('pap.parts',{ 'select_fields' : '0' } )

       else
              let g:{varname}=base#readdatfile(varname)
           endif

"""varupdate_PAP_bibkeys
  elseif varname == 'PAP_bibkeys'

    if base#opttrue('usepsh')
        let g:{varname}=base#splitsystem("pshcmd list bibkeys")
    else

perl << EOF
 
      use LaTeX::BibTeX;
      use Vim::Perl qw( Vim_Files VimLet );
      
      my @keys;
      
      my $bibfile = new LaTeX::BibTeX::File(Vim_Files('bibfile'));
      
      while ($entry = new LaTeX::BibTeX::Entry $bibfile)
      {
        next unless $entry->parse_ok;
        push(@keys,$entry->key);
      }
      VimLet('g:PAP_bibkeys',\@keys);

EOF
      endif

     elseif varname == 'DC_Proj_Defs'
        call base#varcheckexist('proj')
        let g:{varname}=base#readdatfile({ 
                \   'file' : base#catpath('projs', g:proj . '.defs.i.dat' ) ,
                \   'splitlines' : 0,
                \   })
    
     elseif varname == 'TXT_CommentChars'
        let g:{varname}={
              \ 'vim'   : '"',
              \ 'perl'  : '#',
              \ 'tex'   : '%',
              \ }

     elseif varname == 'commentchar'
        let g:{varname}="#"

     elseif varname =~ 'F_'

     else
         let notdone=1
    endif

    if exists('notdone')
          echohl WarningMsg
          echo "base#varupdate> Not yet implemented: " . varname
          echohl None
    endif
 
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

 
"""base_datupdate
fun! base#datupdate(...)

 call base#varcheckexist("datfiles")

 if a:0
   	let dat=a:1
 else
	let dat=base#getfromchoosedialog({ 
	   \ 'list'        : sort(keys(s:datfiles)),
	   \ 'startopt'    : 'datfiles',
	   \ 'header'      : "Available datfiles are: ",
	   \ 'numcols'     : 1,
	   \ 'bottom'      : "Choose datfile by number: ",
	   \ })
 endif

 if ! exists("s:datfiles[dat]")
   return
 endif

 let datfile=get(s:datfiles,dat)

 let lines=[]

"""datupdate_ctags_mkvimrc
 if dat == 'ctags_mkvimrc'
   let ids=[ 'mkvimrc', 'vimcom', 'vimfun' ]
   for id in ids
     call extend(lines,base#splitglob(id,'*.vim'))
   endfor

   for subdir in [ 'plugin', 'autoload', 'ftplugin', 'syntax' ]
   		call extend(lines,split(globpath(&rtp,subdir . '/*.vim'),"\n"))
   endfor

"""datupdate_list_tex_papers
 elseif dat == 'list_tex_papers'

     call extend(lines,
		\ base#uniq(map(base#fnamemodifysplitglob('p','p.*.tex',':p:t:r'),
	 	\	"matchstr(v:val,'^p\\.\\zs\\w\\+\\ze')")))

"""datupdate_perl_installed_modules
 elseif dat == 'perl_installed_modules'
   call extend(lines,base#splitsystem('pmi ^' ) )

"""datupdate_perl_used_modules
 elseif dat == 'perl_used_modules'
   call extend(lines,base#splitsystem('pmi --searchdirs ' 
   	\	. base#catpath('traveltek_modules','') . ' ^ready::ODTDMS::' ))

"""datupdate_perl_local_modules
 elseif dat == 'perl_local_modules'
   call extend(lines,base#splitsystem('pmi --searchdirs ' . $PERLMODDIR . '/lib ^' ))

 elseif dat == ''
   " code
 endif

 call writefile(lines,datfile)

endfun
"" end base#datupdate
 
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
	let exts = [ '' ] 
	
	if exists("ref.exts") | let exts = ref.exts | endif
	if exists("ref.dirs") | let dirs = ref.dirs | endif

	let searchopts = ' /b/a:-d '

	if get(ref,'cwd')
		call add(dirs,getcwd())
	endif

	if get(ref,'subdirs')
		let searchopts .= ' /s '
	endif

	" list of found files to be returned
	let foundfiles = []

	let olddir = getcwd()
	
	for dir in dirs
		let found = ''
		let dir = substitute(dir,'/','\','g')

		exe 'cd ' . dir

		for ext in exts 
			if strlen(ext) | let ext = '.'.ext | endif

			let searchcmd  = 'dir *'.ext.searchopts 
			let res = ap#sys( searchcmd )

			if ! ( res == 'File Not Found' )
				let found .= res . "\n"
			endif

		endfor

		let files=split(found,"\n")

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
					let cf = substitute(cf,'.'.ext.'$','','g') 
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
			"call filter(newfiles,map)
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
			\	"text" : "Need provide input parameter as dictionary", 
			\	"prefix" : prefix })
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
			\	rootdir, subdirs . dat . ref.ext
			\	])
		
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
	\	'path'          : g:path          ,
	\	'ext'           : g:ext           ,
	\	'filename'      : g:filename      ,
	\	'dirname'       : g:dirname       ,
	\	'filename_root' : g:filename_root ,
	\	}
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

fun! base#sys(...)

 let cmds=[]

 let opts={
	\	'custom_error_message': 0   ,
	\	'show_output'  : 0          ,
	\	'prompt'       : 1          ,
	\	'skip_errors'  : 0          ,
	\	}

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

 for cmd in cmds 
    let output = split(system(cmd),"\n")
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

 return ok

endfun

function! base#fileset (ref)

	for [ pathid, path ] in items(a:ref) 
		let e = { pathid : path }
		if ! exists("s:files")
			let s:files=e
		else
			call extend(s:files,e)
		endif
	endfor

endfun

function! base#pathset (ref)

	for [ pathid, path ] in items(a:ref) 
		let e = { pathid : path }
		if ! exists("s:paths")
			let s:paths=e
		else
			call extend(s:paths,e)
		endif
	endfor

endfun

function! base#pathlist ()
	if ! exists("s:paths")
		let s:paths={}
	endif

    let pathlist= sort(keys(s:paths))
	call base#var('pathlist',pathlist)

	return pathlist
	
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
			\	"text"   : "path undefined: " . a:pathid ,
			\	"prefix" : prefix ,
			\	})
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

"""info_statusline
   elseif topic == 'statusline'
	let stl=''
	if exists("g:F_StatusLine")
  		let stl = g:F_StatusLine
	endif

	let stl = base#var('stl')

       call base#echo({ 'text'   : "Statusline: " } )
       call base#echo({ 'text'   : "\t"."g:F_StatusLine =>  " . stl } )
       call base#echo({ 'text'   : "\t"."&stl =>  " . &stl } )
       call base#echo({ 'text'   : "\t"."stl (StatusLine cmd) =>  " . stl } )

"""info_paths
   elseif topic == 'paths'

       call base#echo({ 'text'   : "Paths-related variables: " } )
       call base#echo({ 
	   	\	'text'   : 'pathlist => ' 
	   		\	. "\n\t" . join(base#pathlist()," "), 
	   	\	'indentlev' : indentlev })

"""info_dirs
   elseif topic == 'dirs'

       call base#echo({ 'text'   : "Directory-related variables: " } )
       call base#echovar({ 'var' : 'g:dirs', 'indent' : indentlev })



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

"""info_proj
   elseif topic == 'proj'
	    call projs#info()
       
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
	   	\	. "\n\t" . join(g:plugins,"\n\t"),'indentlev' : indentlev })


"""info_make
   elseif topic == 'make'
       call base#echo({ 'text' : "MAKE: " } )
       call base#echovar({ 'var' : '&makeprg', 'indent' : indentlev })
       call base#echovar({ 'var' : '&efm', 'indent' : indentlev })

       call base#echo({ 
	   	\	'text' : "makeprg id =>  " 
	   	\	. make#var('makeprg') }) 

       call base#echo({ 
	   	\	'text' : "efm id     =>  " 
	   	\	. make#var('efm') }) 

       call base#echo({ 
	   	\	'text' : "cwd        =>  " 
	   	\	. getcwd() }) 

"""info_opts
   elseif topic == 'opts'
       call base#echo({ 'text' : "OPTIONS: " } )
	   call base#varcheckexist('opts')
	   echo base#var('opts')

   endif
 endif
 
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
function! base#varecho (varname)
	echo base#var(a:varname)

endfunction

function! base#varget (varname)

	if ! exists("s:basevars")
		let s:basevars={}
	endif
	
	if exists("s:basevars[a:varname]")
		let val = copy( s:basevars[a:varname] )
	else
		call base#warn({ 
			\	"text" : "Undefined variable: " . a:varname,
			\	"prefix" : "(base#varget) ",
			\	})
		let val = ''
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
			\	"text": 'NO datafile for: ' . varname 
			\	})
		return 0
	endif

	let data = base#readdatfile({ 
		\   "file" : datafile ,
		\   "type" : type ,
		\	})

	call base#var(varname,data)

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
		\	})

	return files
endfunction

function! base#initvars (...)
	call base#echoprefix('(base#initvars)')

	let datfiles = {}
	let datlist  = []

	let mp = { "list" : "List", "dict" : "Dictionary" }
	for type in base#qw("list dict")
		let dir = base#file#catfile([ base#datadir(), type ])
		let vars= base#find({ 
			\	"dirs" : [ dir ], 
			\	"exts" : [ "i.dat" ], 	
			\	"subdirs" : 1, 
			\	"relpath" : 1,
	   		\	"rmext"   : 1, })
		let tp = mp[type]
		for v in vars
			call base#varsetfromdat(v,tp)
			let d = []

			let dfs= base#find({ 
				\	"dirs" : [ dir ], 
				\	"exts" : [ "i.dat" ], 	
				\	"subdirs" : 1, 
				\	"pat"     : v, })
			let df=get(dfs,0,'')

			call add(datlist,v)
			call extend(datfiles,{ v : df }) 
		endfor
	endfor

	call base#var('datlist',datlist)
	call base#var('datfiles',datfiles)

	call base#var('vim_funcs_user',
		\	base#fnamemodifysplitglob('funs','*.vim',':t:r'))

	call base#var('vim_coms',
		\	base#fnamemodifysplitglob('coms','*.vim',':t:r'))

	let varlist = keys(s:basevars)

	call base#var('varlist',varlist)

	call base#echoprefixold()
endf	

function! base#varlist ()
	let varlist = keys(s:basevars)
	call base#var('varlist',varlist)
	return varlist
endfunction

function! base#initplugins (...)

	call base#varsetfromdat('plugins','List')
	let g:plugins=base#var('plugins')

endf	


function! base#init (...)

	" initialize data using base#pathset(...)
	call base#initpaths()

	call base#initplugins()

	call base#initvars()

	" initialize data using base#fileset(...)
	call base#initfiles()

	call base#init#cmds()

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
			
	LFUN OMNI_Select_Completion

  if a:0
    let dat=a:1
  else
    let dat=base#getfromchoosedialog({ 
        \ 'list'        : base#varhash#keys('datfiles'),
        \ 'startopt'    : 'perl_local_modules_to_install',
        \ 'header'      : "Available DAT files are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose DAT file by number: ",
        \ })
  endif

  if has_key(s:datfiles,dat)
    let datfile=s:datfiles[dat]
  else
    call base#subwarn("Given dat file does not exist in s:datfiles dictionary")
  endif

  if dat == '_vimrc_console_funcs_to_load_'
    call OMNI_Select_Completion('vimfuncs')
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
 
 

