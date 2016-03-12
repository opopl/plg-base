
"see LFUN in base/plugin/base_init.vim

fun! base#loadvimfunc(fun)
 
  let fun=a:fun

  let fun=substitute(fun,'\s*$','','g')
  let fun=substitute(fun,'^\s*','','g')

  let fundir=g:dirs.funs

  let funfile=fundir . '/' . fun . '.vim'

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

"""base_viewvimfunc
fun! base#viewvimfunc(...)
  let fun=a:1

  let funfile = base#catpath('funs',fun . '.vim')

  if ! base#vimfuncexists(fun)
    call base#vimfuncnew(fun)
  endif

  call base#fileopen(funfile)

  let g:vimfun=fun

  call base#statusline(fun)
endfun

"""base_viewvimcom
fun! base#viewvimcom(...)
  let com=a:1

  let comfile = base#catpath('coms',com . '.vim')

  "if ! base#vimcomexists(fun)
    "call base#vimcomnew(fun)
  "endif

  call base#fileopen(comfile)

  call base#statusline(comfile)
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

"""base_loadvimcommand
fun! base#loadvimcom(com)

  let com=a:com

  let com=substitute(com,'\s*$','','g')
  let com=substitute(com,'^\s*','','g')

  call base#varcheckexist("dirs")

  let comdir=g:dirs.coms

  let comfile = comdir . '/' . com . '.vim'

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

"""base_setpaths
fun! base#initpaths()
 
"""define_paths
    let s:paths={}

	let confdir   = base#envvar('CONFDIR')
	let vrt       = base#envvar('VIMRUNTIME')
	let hm        = base#envvar('hm')
	let mrc       = base#envvar('MYVIMRC')
	let projsdir  = base#envvar('PROJSDIR')

	call base#pathset({ 
			\ 'conf' : confdir ,
			\ 'vrt'  : vrt,
			\	})

	let mkvimrc = base#file#catfile([ base#path('conf'), 'mk', 'vimrc' ])
	let mkbashrc = base#file#catfile([ base#path('conf'), 'mk', 'bashrc' ])

	call base#pathset({
		\	'mkvimrc' : mkvimrc,
		\	'mkbashrc' : mkbashrc,
		\	'coms' : base#file#catfile([ mkvimrc, '_coms_' ]) ,
		\	'funs' : base#file#catfile([ mkvimrc, '_fun_' ]) ,
		\	'projs' : projsdir,
		\	'perlmod' : base#file#catfile([ hm, base#qw("repos git perlmod") ]),
		\	'perlscripts' : base#file#catfile([ hm, base#qw("scripts perl") ]),
		\	'scripts' : base#file#catfile([ hm, base#qw("scripts") ]),
		\	})
	
"    let s:paths={
"        \ 'aptmirror'  	  :         g:hm . '/doc/mirrors/apt',
"        \ 'autoload' :     g:vrt . '/autoload/',
"        \ 'cit' :         $hm . '/doc/cit',
"        \ 'cvim'   :       g:confdir . '/mk/vimrc/',
"        \ 'dict'   :       g:confdir . '/mk/vimrc/dict/',
"        \ 'docperltex'    :         '/doc/perl/tex',
"        \ 'ftplugin'  :    g:vrt . '/ftplugin',
"        \ 'gittest' :         $hm . '/wrk/clones/gittest',
"        \ 'gops'   :       g:hm . '/gops/',
"        \ 'gops_scripts' : g:hm . '/gops/scripts/all',
"        \ 'lasu'         :    g:vrt . '/ftplugin/latex-suite',
"        \ 'menuicons' :         $hm . '/icons/vim',
"        \ 'mkbashrc'   :    g:confdir . '/mk/bashrc/',
"        \ 'mkvimrc'   :    g:confdir . '/mk/vimrc/',
"        \ 'p'  :           $hm . '/wrk/p',
"        \ 'pdfdocs'     :    $PDFDOCS,
"        \ 'pdfout'      :    $PDFOUT,
"        \ 'pdfpaps'  :        $hm . '/doc/papers/ChemPhys/',
"        \ 'perlmod' :      g:hm . '/wrk/perlmod/',
"        \ 'perlscripts'  : g:hm . '/scripts/perl/',
"        \ 'pl'    :        g:vrt . '/plugin/',
"        \ 'plugin'   :     g:vrt . '/plugin/',
"        \ 'projs'   :      g:hm . '/wrk/texdocs/',
"        \ 'scripts' :      g:hm . '/scripts/',
"        \ 'sni'  :         g:vrt . '/snippets/',
"        \ 'tags' :         g:hm . '/tags',
"        \ 'tests'     :    g:hm . '/wrk/clones/tests',
"        \ 'tex'              :    $texdir,
"        \ 'texdist' : '/usr/share/texlive/texmf-dist/tex/latex',
"        \ 'texdocs' :      g:hm . '/wrk/texdocs',
"        \ 'texinputs' :    g:hm . '/wrk/texinputs',
"        \ 'texpacks'         :    $texdir . '/texmf-dist/tex/latex/',
"        \ 'traveltek_filer' :    g:hm . '/wrk/traveltek/filer/',
"        \ 'traveltek_modules' :    g:hm . '/wrk/traveltek/filer/modules',
"        \ 'traveltek_odtdms' :    g:hm . '/wrk/traveltek/filer/odtdms',
"        \ 'vim'  :         g:vrt,
"        \ 'vimcom'  :      g:confdir . '/mk/vimrc/_coms_/',
"        \ 'vimprojects'  :    g:confdir . '/mk/vimrc/_projects_/',
"        \ 'vimsnips'  :    g:confdir . '/mk/vimrc/_snippets_/',
"        \ 'vimdoc'  :      g:vrt . '/doc',
"        \ 'vimfun'  :      g:confdir . '/mk/vimrc/_fun_/',
"        \ 'vrt'  :         g:vrt,
"        \}

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

 let action = 'split'

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
    call base#subwarn("wrong type of input argument 'opts' - should be Dictionary")

    return
  endif

  let numcols  = 1
  let startopt = ''
  let header   = 'Option Choose Dialog'
  let bottom   = 'Choose an option: '
  let selected = 'Selected: '

  let keystr= "list startopt numcols header bottom selected"
  for key in base#qw(keystr)
      if has_key(a:opts,key)
        exe 'let ' . key . '=a:opts.' . key
      endif
  endfor

  try 
      let liststr=join(list,"\n")
  catch
    call base#subwarn("input list of options was not provided")
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

fun! base#statusline(...)

    if a:0
      let opt=a:1
    else
      let opt='neat'

      let listcomps=g:F_StatusLineKeys
  
      let liststr = join(listcomps,"\n")
      let dialog  = "Available status line keys  are: " . "\n"
      let dialog .= base#createprompt(liststr, 1, "\n") . "\n"
      let dialog .= "Choose status line key by number: " . "\n"

      let opt = base#choosefromprompt(dialog,liststr,"\n",'neat')
      echo "Selected: " . opt

    endif


    if exists('g:F_StatusLines')
        let sline  = get(g:F_StatusLines,opt)
        let evs    = "setlocal statusline=" . sline
        let g:F_StatusLine      = opt
        let g:F_StatusLineOrder = []

        if exists('g:F_StatusLineOrders[opt]')
            let g:F_StatusLineOrder=g:F_StatusLineOrders[opt]
        endif
    endif

    exe evs
endfun

 
fun! base#setstatuslines(...)

  let g:F_StatusLineOrders={}

  let g:F_StatusLines={
    \  'enc' : '%<%f%h%m%r%=format=%{&fileformat}\ file=%{&fileencoding}\ enc=%{&encoding}\ %b\ 0x%B\ %l,%c%V\ %P',
        \  'vim_COM' :   ''
                \   . '\ %{expand(' . "'" . '%:~:t:r' . "'" . ')}' ,
    \   }

  for key in keys(g:F_StatusLines)
    let g:F_StatusLineOrders[key]=[]
  endfor

  call base#setstatuslineparts()

  let g:F_StatusLineOrders={
        \   'enc'   :   [ 
                \   'file_name',
                \   'file_format',
                \   'file_type',
                \   'encoding',
                \   'file_encoding',
                \       ],
        \   'perl_pm'   :   [ 
		        \   'perl_module_name',
                \           ],
        \   'perl_pl'   :   [ 
		        \   'file_name',
		        \   'file_dir',
                \       ],
        \   'simple'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   'file_encoding',
                \       ],
        \   'neat'   :   [ 
		        \   'mode',
		        \   'session_name',
		        \   'file_name',
		        \   'file_flags',
		        \   'right_align',
		        \   'read_only',
		        \   'file_type',
		        \   'file_format',
		        \   'file_encoding',
		        \   'buffer_number',
		        \   'is_modified',
		        \   ],
        \   'vimfun'   :   [ 
		        \   'vimfun',
		        \   ],
        \   'vimproject'   :   [ 
		        \   'vimproject',
		        \   ],
        \   'vim'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   ],
        \   'dat'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   ],
        \   'sh'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   ],
        \   'bush'   :   [ 
		        \   'bush_name',
		        \   ],
        \   'vimcom'   :   [ 
		        \   'vimcom',
		        \   ],
        \   'projs'   :   [ 
		        \   'projs_proj',
		        \   'projs_sec',
		        \   'fold_level',
		        \   ],
        \   }

  let g:F_StatusLineKeys=sort(keys(g:F_StatusLineOrders))

  LCOM SafeLet

  for var in [ 'F_StatusLineBefore', 'F_StatusLineAfter' ]
 	call base#setglobalvarfromdat(var, { 'splitlines': 1 } )
  endfor

  for key in g:F_StatusLineKeys
       let stl=''

       let idlist=[]
       let idlist=copy(g:F_StatusLineBefore)
       call extend(idlist,g:F_StatusLineOrders[key])
       call extend(idlist,g:F_StatusLineAfter)

       for id in idlist
         let stl.='\ ' . g:stlparts[id]
       endfor

       let g:F_StatusLines[key]=stl
  endfor

""========================================================
  let g:F_StatusLines['perl_']=g:F_StatusLines['perl_pl']

endfun

fun! base#setstatuslineparts()

 LFUN F_IgnoreCase
 LFUN F_SoPiece

 "call base#sopiece("NeatStatusLine.vim")
 call F_SoPiece("NeatStatusLine.vim")

"""stl_neat
  let g:stlparts={}

    " mode (changes color)
  let g:stlparts['mode']= '%1*\ %{NeatStatusLine_Mode()}\ %0*' 

  let g:stlparts['fold_level']="%5*%{foldlevel(line('.'))}%0*"

"""stl_neat_session_name
    " session name
  let g:stlparts['session_name']='%5*\ %{g:neatstatus_session}\ %0*' 

"""stl_neat_file_path
    " file path
  let g:stlparts['file_name']="%{expand('%:p:t')}" 

  let g:stlparts['bush_name']="%{expand('%:p:t:r')}" 

  let g:stlparts['file_dir']="%{expand('%:p:h:')}" 

  let g:stlparts['full_file_path']="%{expand('%:p')}" 

"""stl_neat_file_flags
    " read only, modified, modifiable flags in brackets
  let g:stlparts['file_flags']='%([%R%M]%)' 
    
  " right-align everything past this point
  let g:stlparts['right_align']= '%=' 
    
"""stl_neat_read_only
  " readonly flag
  let g:stlparts['read_only']="%{(&ro!=0?'(readonly)':'')}"
        
  " file type (eg. python, ruby, etc..)
  let g:stlparts['file_type']= '%8*%{&filetype}%0*' 

  let g:stlparts['keymap']= '%8*%{&keymap}' 

  " file format (eg. unix, dos, etc..)
  let g:stlparts['file_format']='%{&fileformat}'

  " file encoding (eg. utf8, latin1, etc..)
  let g:stlparts['file_encoding']= "%4*%{(&fenc!=''?&fenc:&enc)}%0*"

  let g:stlparts['encoding']= "%4*%{&enc}%0*"

  " buffer number
  let g:stlparts['buffer_number']='#%n'

  "line number (pink) / total lines
  let g:stlparts['line_number']='%4*\ %l%0*'

  " column number (minimum width is 4)
  let g:stlparts['column_number']='%3*\ %-3.c%0*'

  let g:stlparts['ignore_case']='%{F_IgnoreCase()}'

    let g:stlparts['color_red']='%3*'
    let g:stlparts['color_blue']='%8*'
    let g:stlparts['color_white']='%0*'

    " percentage done
    let g:stlparts['percentage_done']='(%-3.p%%)'

    " modified / unmodified (purple)
    let g:stlparts['is_modified']="%6*%{&modified?'modified':''}"

    let g:stlparts['projs_proj']= '%1*\ %{g:proj}\ %0*' 
    let g:stlparts['projs_sec']= '%7*\ %{g:DC_Proj_SecName}\ %0*' 

    let g:stlparts['vimfun']= '%1*\ %{g:vimfun}\ %0*' 
    let g:stlparts['vimcom']= '%1*\ %{g:vimcom}\ %0*' 
    let g:stlparts['vimproject']= '%1*\ %{g:vimproject}\ %0*' 

    let g:stlparts['stlname']= '%2*\ %{g:F_StatusLine}\ %0*' 

    let g:stlparts['tags']= '%{fnamemodify(&tags,' . "'" . ':~' . "'" . ')}' 

    let g:stlparts['makeprg']='%1*\ %{&makeprg}' 

	"call base#varupdate('PMOD_ModuleName')
    let g:stlparts['perl_module_name']='%5*\ %{g:PMOD_ModuleName}\ %0*' 
    let g:stlparts['path_relative_home']='%{expand(' . "'" . '%:~:t' . "'" . ')}'

endfun


fun! base#readdatalist(id)
	
	let list=base#readdatfile({ "file" : file, "type" : "List" })

endfun

fun! base#readdatfile(ref,...)

 call base#varcheckexist('datfiles')

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
    \   'splitlines'    : 1,
    \   'uniq'          : 0,
    \   'select_fields' : 'all',
    \   'sep'           : '\s\+',
    \   'joinsep'       : ' ',
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
       let g:{varname}=base#find({ 
            \   'path'          : 'vimsnips',
            \   'ext'           : 'vim',
            \   'fnamemodify'   : ':p:t:r',
            \   })


"""pdf_perldoc
     elseif varname == 'pdf_perldoc'
       let g:{varname}=base#find({
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
      let g:{varname}=base#find({ 
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

        let g:perl_used_modules_paths=base#readdictDat('perl_used_modules')

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
            LFUN F_ListNewInc

            call base#varreset(varname,{})

"""_pdf_docs
            if exists("s:paths.pdfdocs")
                
                let dir=s:paths['pdfdocs']
                let docs={}

                if len(dir) 
    
                    let docs[dir]=base#fnamemodifysplitglob('pdfdocs','*.pdf',':p:t:r')
        
                    let docs[dir]=base#find({  'path'              : 'pdfdocs', 
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
                          \    '~/wrk/ap/oia/UC/': map(F_ListNewInc(0,30,1),"'UC-' . v:val")
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

	  call base#var('datfiles',s:datfiles)
	  call base#var('datlist',base#varhash#keys('datfiles'))

"""varupdate_allmenus
      elseif varname == 'allmenus'
          LCOM PrjMake
          LFUN F_ListNewInc

          let g:{varname}={}

          for i in F_ListNewInc(1,10,1)
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
          let files=base#find({
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
       let g:{varname}=sort(base#find({
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
       let files=sort(base#find({
          \ 'dir' : g:texlive['TEXMFDIST'] . '/' . dir,
          \ 'ext' : 'tex,env,4ht',
          \} ))
       
       call map(files,"matchstr(v:val,'^' . g:texlive['TEXMFDIST'] . '/\\zs.*\\ze$' )")

       call extend(g:{varname},files)
     endfor

     elseif varname == 'TEX_PlainTexExamples'
       let g:{varname}=sort(base#find({
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
       let g:{varname}=base#find({ 
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
        let g:{varname}=base#find( { 
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

            let g:plugindirs=base#find({ 
                \   'dir'       : g:plugindir,
                \   'type'      : 'd',
                \   'maxdepth'  : 1,
                \   'mindepth'  : 1,
                \   'fnamemodify'  : ':t',
                \   } )

            let g:{varname}=base#find({ 
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
 
 
" input: Dictionary
" return: List

fun! base#find(ref)

 if ( base#type(a:ref) != 'Dictionary' )
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

 let g:fileinfo={
	\	'path'          : g:path          ,
	\	'ext'           : g:ext           ,
	\	'filename'      : g:filename      ,
	\	'dirname'       : g:dirname       ,
	\	'filename_root' : g:filename_root ,
	\	}

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
	\	'custom_error_message': 0 ,
	\	'show_output': 0          ,
	\	}

 if a:0 
   if base#type(a:1) == 'String'
		 	let cmd=a:1
		 	let cmds=[ cmd ] 
   	
   elseif base#type(a:1) == 'List'
		 	let cmds=a:1
   	
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
    if v:shell_error
        echohl ErrorMsg
        echo errormsg
				if opts.custom_error_message == 0
						echo cmd
				endif
        echohl None

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

				let ok=0
    endif
 endfor

 return ok

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

"""base_path
function! base#path (pathid)
	let prefix=''

	if exists("s:paths[a:pathid]")
		let path = s:paths[a:pathid]
	else
		let path = ''

		call base#warn({ 
			\	"text"   : "path undefined: " . a:pathid ,
			\	"prefix" : prefix ,
			\	})
	endif

	let prefix = '( base#path ) '
	
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

	let prefix=''
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

       call base#echo({ 'text' : "Current directory: " } )
       echo indent . expand('%:p:h')

       call base#echo({ 'text' : "Filetype: " } )
       echo indent . &ft

       call base#echo({ 'text' : "Other variables: " } )
       call base#echovar({ 'var' : 'g:dirname', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:filename', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:path', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:ext' , 'indent' : indentlev })

"""info_plugins
   elseif topic == 'plugins'

"""info_dirs
   elseif topic == 'dirs'

       call base#echo({ 'text'   : "Directory-related variables: " } )
       call base#echovar({ 'var' : 'g:dirs', 'indent' : indentlev })

"""info_paths
   elseif topic == 'paths'

       call base#echo({ 'text'   : "Paths-related variables: " } )
       call base#echovar({ 'var' : 's:paths', 'indent' : indentlev })

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
"""info_vhooks
"   elseif topic == 'vhooks'
       "LFUN VH_GetHooks
       "call base#echo({ 'text' : "VimHelp Hooks ", 'hl' : 'Title' } )

	   "call VH_GetHooks()
	   "call F_VarUpdate('vhookTOC')

       "call base#echovar({ 'var' : 'g:vhookroot', 'indent' : indentlev })
       "call base#echovar({ 'var' : 'g:vhookTOCexists', 'indent' : indentlev })

       "if exists("g:vhookTOCexists")
		   "if g:vhookTOCexists
			   "call base#echovar({ 'var' : 'g:vhookTOCSTART', 'indent' : indentlev })
			   "call base#echovar({ 'var' : 'g:vhookTOCEND', 'indent' : indentlev })
		   "endif
       "endif

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
       call base#echo({ 'text' : "Tags: " } )
       call base#echovar({ 'var' : 'g:CTAGS_CurrentTagID', 'indent' : indentlev })
       call base#echovar({ 'var' : '&tags', 'indent' : indentlev, 'spliton' : ',' })
       call base#echovar({ 'var' : 'g:ctagscmd', 'indent' : indentlev, 'spliton' : ',' })
       call base#echovar({ 'var' : 'g:ctagsexe', 'indent' : indentlev,  })
       call base#echovar({ 'var' : 'g:tagfile', 'indent' : indentlev, })
       call base#echovar({ 'var' : 'g:tagfiles', 'indent' : indentlev, })
       call base#echovar({ 'var' : 'g:tagdir', 'indent' : indentlev,  })

"""info_proj
   elseif topic == 'proj'
       if exists("g:proj")
           call base#echo({ 'text' : "PROJECTS ", 'hl' : 'Title' } )

           call base#echo({ 'text' : "Current project: " } )
           call base#echovar({ 'var' : 'g:proj', 'indent' : indentlev })

           call base#echo({ 'text' : "Current section: " } )
           call base#echovar({ 'var' : 'g:DC_Proj_SecName', 'indent' : indentlev })

       endif

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

"""info_make
   elseif topic == 'make'
       call base#echo({ 'text' : "MAKE: " } )
       call base#echovar({ 'var' : '&makeprg', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:F_MakePrg', 'indent' : indentlev })
       call base#echovar({ 'var' : 'g:F_ErrorFormat', 'indent' : indentlev })

"""info_opts
   elseif topic == 'opts'
       call base#echo({ 'text' : "OPTIONS: " } )
	   call base#varcheckexist('opts')
	   echo base#var('opts')

   endif
 endif
 
endfun

fun! base#echo(opts)
  let opts=a:opts

  let hl='MoreMsg'
  if exists("g:hl")
     let hl=g:hl
  endif
  if exists("opts.hl")
     let hl=opts.hl
  endif

  exe "echohl " . hl
  echo opts.text
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
   let indentlev = a:ref.indent
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

function! base#datadir ()
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

function! base#varecho (varname)
	echo base#var(a:varname)

endfunction

function! base#varget (varname)
	
	if exists("s:basevars[a:varname]")
		let val = s:basevars[a:varname]
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
	let datadir = base#datadir()
	let file = a:id . ".i.dat"
	let file = base#file#catfile([ datadir, file ])
	return file
endfunction

function! base#initvars (...)
	let s:basevars={}
endf	

function! base#init (...)
	
	let datvars  =''
	let datvars .=' opts info_topics '

	let dathashvars  =''
	let dathashvars .=' datfiles '

	let e={
		\	"varsfromdatlist" : base#qw(datvars),
		\	"varsfromdathash" : base#qw(dathashvars),
		\	}

	if exists("s:basevars")
		call extend(s:basevars,e)
	else
		let s:basevars=e
	endif

	for v in base#var('varsfromdat')
		call base#varsetfromdat(v,"List")
	endfor

	for v in base#var('varsfromdathash')
		call base#varsetfromdat(v,"Dictionary")
	endfor

	call base#initpaths()

	call base#var('vim_funcs_user',
		\	base#fnamemodifysplitglob('funs','*.vim',':t:r'))

	call base#var('vim_coms',
		\	base#fnamemodifysplitglob('coms','*.vim',':t:r'))

	let varlist = keys(s:basevars)

	call base#var('varlist',varlist)

    "call base#setstatuslines()
	"
	return 1

endfunction


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
 
 
