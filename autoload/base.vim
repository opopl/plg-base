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

  let viewer = base#exefile#path('evince')

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

 let ref = a:1
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

function! base#htmlwork (...)
	let cmd  = get(a:000,0,'')
	let cmds = base#varget('htmlwork',[])

	if base#inlist(cmd,cmds)
		let sub = 'call base#htmlwork#'.cmd.'()'
		exe sub
	endif

	
endfunction

function! base#CD(pathid, ... )
    let ref = {}

		let pathid = a:pathid

    if a:0 | let ref = a:1 | endif

    let dir = base#path(pathid)
		call base#varset('pathid',pathid)
    if isdirectory(dir)
        call base#cd(dir,ref)
    else
        call base#warn({ "text" : "Is NOT a directory: " . dir })
    endif
endf


function! base#cd(dir,...)
    let ref = {}
    if a:0 | let ref = a:1 | endif

		let dir = a:dir
		let dir = base#file#win2unix(dir)

    let ech = get(ref,'echo',1)

    if ech
				try 
					if isdirectory(dir)
	        	silent exe 'cd ' . dir
		        echohl MoreMsg
		        echo 'Changed to: ' . dir
		        echohl None
					endif
				endtry

				let cwd = getcwd()

    endif
endf

function! base#isdict(var)
  if type(a:var) == type({})
    return 1
  endif
  return 0
endf

function! base#islist(var)
  if type(a:var) == type([])
    return 1
  endif
  return 0
endf

function! base#dbnames ()
	let dbfile = base#dbfile()
	
	let q = 'SELECT dbname FROM dbfiles WHERE dbdriver = ?'
	let p = ['sqlite']
	let dbnames = pymy#sqlite#query_as_list({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})
	return dbnames

endf

function! base#htw_dbfile()
		let dbdir = $HOME . '/db'
		let dbfile = dbdir . '/html_work.sqlite'
		call base#varset('htw_dbfile',dbfile)
		return dbfile
endf

function! base#dbfile_tmp (...)
		let dbfile = base#dbdir() . '/tmp_vim_base.db'
		return dbfile
endf

function! base#dbdir (...)
		let dbdir = $HOME . '/db'
		call base#mkdir(dbdir)
		return dbdir
endf

function! base#dbfile (...)
	let dbname = get(a:000,0,'')

	if !strlen(dbname)
		let dbdir = base#dbdir()
	
		let dbfile = dbdir . '/vim_plg_base.db'
	else
		let q = 'SELECT dbfile FROM dbfiles WHERE dbname = ?'
		let p = [dbname]
		let r = pymy#sqlite#query_as_list({
			\	'dbfile' : base#dbfile(),
			\	'p'      : p,
			\	'q'      : q,
			\	})
		let dbfile = get(r,0,'')
	endif

	let dbfile = base#file#win2unix(dbfile)

	return dbfile
endfunction

function! base#log (msg,...)
	let msg = a:msg

	let ref = get(a:000,0,{})
	let log = base#varget('base_log',[])

	let prf = base#varget('base_log_prf','')
	let prf = get(ref,'prf',prf)

	let fnc      = get(ref,'func','')
	let plugin   = get(ref,'plugin','')
	let loglevel = get(ref,'loglevel','')

	let v_exception = get(ref,'v_exception','')

	let do_echo = get(ref,'echo',0)

	if base#type(a:msg) == 'String'
		let time = strftime("%Y %b %d %X")

		if !exists('g:time_start')
			let g:time_start = localtime()
		endif
			
		let elapsed = localtime() - g:time_start

		let msg_prf   = prf.' '.a:msg
		let msg_full  = '<<' . time . '>>' .' '.msg_prf

		call extend(ref,{ 
			\ 'msg'  : msg_full,
			\ 'time' : time,
			\ 'func' : fnc,
			\	})
		call add(log,ref)
		call base#varset('base_log',log)

		let p = [time,loglevel,elapsed,msg,prf,fnc,plugin,v_exception]
		let q = 'INSERT OR IGNORE INTO log (time,loglevel,elapsed,msg,prf,func,plugin,v_exception) VALUES(?,?,?,?,?,?,?,?)'
python << eof

import vim
import sqlite3

#------------------------------------------------------------
def table_exists (ref):
	table  = ref.get('table')
	cur    = ref.get('cur')
	dbfile = ref.get('dbfile')
	tables = []
	q='''
		SELECT 
			name 
		FROM 
			sqlite_master
		WHERE 
			type IN ('table','view') AND name NOT LIKE 'sqlite_%'
		UNION ALL
		SELECT 
			name 
		FROM 
			sqlite_temp_master
		WHERE 
			type IN ('table','view')
		ORDER BY 1
	'''
	if cur:
		cur.execute(q)
		rows = cur.fetchall()
		tables = map(lambda x: x[0], rows)
		if table in tables:
			return 1
	return 0
#------------------------------------------------------------
	
base_dbfile = vim.eval('base#dbfile()')
q = vim.eval('q')
p = vim.eval('p')

base_conn = sqlite3.connect(base_dbfile)
base_cur = base_conn.cursor()

#*******************************
if not table_exists({ 'table' : 'log', 'cur' : base_cur }):
	q = '''
				CREATE TABLE IF NOT EXISTS log (
					msg TEXT,
					time INTEGER,
					elapsed INTEGER,
					loglevel TEXT,
					func TEXT,
					plugin TEXT,
					prf TEXT,
					v_exception TEXT
				);
	'''
	base_cur.execute(q)
#*******************************

base_cur.execute(q,p)

base_conn.commit()
base_conn.close()


eof
		
		if do_echo
			echo msg_prf
		endif

		return 1
	elseif base#type(a:msg) == 'List'
		let msgs = a:msg

		try
			for msg in msgs
				call base#log(msg,ref)
			endfor
		catch /E731/ 
			echo msgs
		endtry
		return 1
		
	endif

	return 1
	
endfunction

function! base#noperl()
	if !has('perl') | call base#log( 'NO PERL INSTALLED' ) | return 1 | endif

	return 0

endfunction

"" DIR - list directory contents 

function! base#DIR(...)
		let refdef={
			\	'exts'         : [],
			\	'ask_for_exts' : 1,
			\	}

		let opt   = get(a:000,0,'')
		let refin = get(a:000,1,{})

		let ref={}
		call extend(ref,refdef)
		call extend(ref,refin)

		let spc = base#qw(' _buf_dirname_ _cwd_ ')

		if opt == ''
			let opt = '_cwd_'
		endif

		if base#inlist(opt,spc)
			if opt == '_buf_dirname_'
				let dir = b:dirname

			elseif opt == '_cwd_'
				let dir = getcwd()
				"call extend(ref,{'ask_for_exts' : 0})

			endif
		elseif base#inlist(opt,base#pathlist())
			let dirid = opt
    	let dir   = base#path(dirid)
		endif

		let exts=get(ref,'exts',[])
		if get(ref,'ask_for_exts')
			let exts_s = input('Extensions (separated by space):','')
			let exts   = base#qw(exts_s)
		endif

		let rlp = input('Relative path (1-relative 0-full)? 1/0: ',0)

		let pat = ''
		let ff  = base#find({ 
			\	"dirs"    : [dir],
			\	"exts"    : exts,
			\	"cwd"     : 1,
			\	"subdirs" : 1,
			\	"pat"     : pat,
			\	"fnamemodify" : '',
			\	})
		if rlp
			let ff = map(ff,'base#file#reldir(v:val,dir)')
		endif

		call base#buf#open_split({ 'lines' : ff })

endfunction


"call base#catpath(key,[a,b,c])

"""base_catpath
fun! base#catpath(key,...)
 
 if !exists("s:paths")
    "call base#initpaths()
		let s:paths={}
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



" Usage: 
" 	base#fileopen({ 'files' : [file], 'exec' : 'set ft=html' })
" 	base#fileopen({ 
" 		\	'files' : [ file ], 
" 		\	'exec'  : [ 'set ft=html' ],
" 		\	})
" 	base#fileopen([ file1, file2])
"
" 	base#fileopen({ 
" 		\	'files'   : [ file ],
" 		\	'Fc'      : Fc,
" 		\	'Fc_args' : Fc_args,
" 		\	})

 
"""base_fileopen
fun! base#fileopen(ref)
	 let ref = a:ref
	
	 let files = []
	
	 let action = 'edit'
	 let action = base#varget('fileopen_action',action)
	
	 let opts={}
	
	 if base#type(ref) == 'String'
	   let files = [ ref ] 
	   
	 elseif base#type(ref) == 'List'
	   let files = ref  
	   
	 elseif base#type(ref) == 'Dictionary'
	   let files   = get(ref,'files',[])
	   let action  = get(ref,'action',action)
	
	   call extend(opts,ref)
	   
	 endif

	 let prf = { 
		 	\	'func'   : 'base#fileopen',
		 	\	'plugin' : 'base',
		 	\	}
	 call base#log([
		 	\	'opening files => ' . base#dump(files),
		 	\	],prf)
	
	 let anew_if_absent = get(opts,'anew_if_absent',0)
	 let load_buf       = get(opts,'load_buf',0)
	
	 for file in files
		if ! filereadable(file)
			if ! anew_if_absent
				continue
			endif
		endif

 " if base#buffers#file_is_loaded(file)
		"let nr = bufnr(file)
		"if load_buf
			"exe 'buffer ' . nr
		"endif
		"continue
	"endif

  exe action . ' ' . file

  let au      = get(opts,'au',{})
  for [ aucmd, auexec ] in items(au)
    
    let f = base#file#win2unix(fnamemodify(':p',file))
    exe join(['aucmd', aucmd, f, auexec ],' ')
    
  endfor

  let Fc      = get(opts,'Fc','')
  let Fc_args = get(opts,'Fc_args',[])

  if type(Fc) == type(function('call'))
		try
    	call call( Fc, Fc_args )
		catch 
			let msg = [
				\	'callback fail:', 
				\	'  args        => ' . base#dump(Fc_args),
				\	]
			let prf = {
				\	'loglevel'    : 'warn',
				\	'v_exception' : v:exception,
				\	'plugin'      : 'base',
				\	'func'        : 'base#fileopen'
				\	}
			call base#log(msg,prf)
		endtry
  endif

  let exec = get(opts,'exec','')

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

fun! base#eval(expr)
	let expr = a:expr

	let val = exists(expr) ? eval(expr) : ''
	return val

endfun

function! base#getfromchoosedialog_nums (ref)
  let ref  = a:ref
  let opts = get(ref,'list',{})

  let defs = {
      \ 'startopt' : 'usual',
      \ 'header'   : '',
      \ 'numcols'  : 1,
      \ 'bottom'   : "",
      \ }

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
 let ref = a:ref

 if a:0 
    if base#type(a:1) == 'Dictionary'
        call extend(opts,a:1)
    endif
 endif

 if base#type(ref) == 'String'
		let datid = ref
		let file = base#datafile(datid)

 elseif base#type(ref) == 'Dictionary'
   call extend(opts,ref)

   let file = get(ref,'file','')
 endif

 if opts.type == 'Dictionary'
    let ref = opts
    call extend(ref,{ 'file' :  file } )
    let res = base#readdict( ref )

 elseif opts.type == 'List'
    let res = base#readarr(file,opts)

 elseif opts.type == 'ListLines'
		call extend(opts,{ 'splitlines' : 0 })
    let res=base#readarr(file,opts)

 else
 		let res=[]

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

fun! base#trim(ivar)
 
  let var=a:ivar

  let var=substitute(var,'^\s*','','g')
  let var=substitute(var,'\s*$','','g')

  return var

endf

"call base#prompt(msg,default)
"call base#prompt(msg,default,complete)

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

fun! base#input(msg,default,...)
  let [msg,default] = [ a:msg,a:default ]

  let ref = get(a:000,0,{})

  let prompt = 1

  let o      = base#varget('opts',{})
  let prompt = get(o,'base#input_prompt',prompt)

  let prompt = get(ref,'prompt',prompt)
  let do_redraw = get(ref,'do_redraw',0)

  if !prompt
    return
  endif

  if do_redraw
		 redraw!
  endif

  let complete = get(ref,'complete','')

  if strlen(complete)
    let v = input(msg,default,complete)
  else
    let v = input(msg,default)
  endif

  return v
endf

fun! base#input_we(msg,default,...)
  let [msg, default] = [ a:msg, a:default ]

  let ref = get(a:000,0,{})

  let complete  = get(ref, 'complete' , '')
  let hist_name = get(ref, 'hist_name' , '')

	let hist = []
  if strlen(hist_name)
		 let hist = base#varget(hist_name,[])
		 let complete = 'custom,base#complete#this'
		 call base#varset('this',hist)
	endif

	let v = ''
  if strlen(complete)
		while !strlen(v)
    	let v = input(msg,default,complete)
		endw

  	if strlen(hist_name)
			call add(hist, v)
		 	call base#varset(hist_name,hist)
		endif
  else
		while !strlen(v)
    	let v = input(msg,default)
		endw
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
          \ })

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
    
        call base#varset('stl_gitcmd_fulldir',fulldir)
        call base#varset('stl_gitcmd_dirname',dirname)
        call base#varset('stl_gitcmd_cmd',gitcmd)

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
  call base#varset('psopts',psopts)

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

"		[ 'vim', 'dat' ]=> '*.vim' '*.dat'
"call base#mapsub(base#qw('vim dat'),'^','*.','g') 

fun! base#mapsub(array,pat,subpat,subopts)

  let arr = copy(a:array)

  call map(arr,"substitute(v:val,'" . a:pat .  "','" . a:subpat . "','" . a:subopts . "')")

  return arr
endf

"let a = base#mapsub_join(base#qw('vim dat'),'^','*.','g',' ') 

fun! base#mapsub_join(array,pat,subpat,subopts,delim)
	return join(base#mapsub(a:array,a:pat,a:subpat,a:subopts),a:delim)

endf

function! base#varremove(...)
	let var = get(a:000,0,'')

  if ! exists("s:basevars")
    let s:basevars={}
		return
  endif

	if has_key(s:basevars,var)
		call remove(s:basevars,var)
	endif
 
endfunction

 
fun! base#readdictdat(ref)
 
 let ref=a:ref

 let opts={}

 call base#varcheckexist('datfiles')

 if base#type(ref) == 'String'
   let opts['file'] = s:datfiles[ref]

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

    let files = base#find#withperl(a:ref)

    return files

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

 let ref = a:ref

 let opts = {}
 if a:0
   let opts = a:1
 endif

 if type(ref) == type( "" )
     let varname = ref
 elseif type(ref) == type([])
     for dat in ref
         call base#setglobalvarfromdat(dat,opts)
     endfor

     return
 endif

 let varname = substitute(varname,'^g:','','g')

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

 let path     = ''
 let fileinfo = {}

 let ids=[ '<afile>', '<buf>', '%' ] 
 
 while !filereadable(path) && len(ids)
    let id     = remove(ids,-1)
    let path   = expand(id . ':p')
 endwhile

 if !filereadable(path)
    return {}
 endif

 let dirname  = fnamemodify(path,':h')
 let filename = fnamemodify(path,':t')

 " root filename without all extensions removed
 let filename_root = get(split(filename,'\.'),0)

 let ext = fnamemodify(path, ':e')

 let pathids  = base#buf#pathids()
 let fileinfo = {
    \   'path'          : path          ,
    \   'ext'           : ext           ,
    \   'filename'      : filename      ,
    \   'dirname'       : dirname       ,
    \   'filename_root' : filename_root ,
    \   'filetype'      : &ft,
    \   'pathids'       : pathids,
    \   }

 let fileinfo   = fileinfo
 let b:fileinfo = fileinfo

 return fileinfo

endfun

fun! base#sys_split_output(...)
	let cmd = join(a:000,' ')
	let hist = base#varget('hist_basesys',[])

	call base#sys({ 
		\	"cmds"         : [cmd],
		\	"split_output" : 1,
		\	})
	call add(hist,cmd)
	call base#uniq(hist)

	call base#varset('hist_basesys',hist)

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
    \   'split_output' : 0         ,
    \   'write_to_bat' : ''        ,
    \   'use_vimproc'  : 0        ,
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

 let output    = []
 let outputstr = ''

 let write_to_bat=get(opts,'write_to_bat','')
 if strlen(write_to_bat)
    if filereadable(write_to_bat)
      call delete(write_to_bat)
    endif
    
    call writefile(cmds,write_to_bat)
    if filereadable(write_to_bat)
      let cmds_orig = cmds
      let cmds      = [write_to_bat]
    endif
 endif

 let use_vimproc = get(opts,'use_vimproc',0)

 for cmd in cmds 
		if use_vimproc
    	let outstr = vimproc#system(cmd)
		else
    	let outstr = system(cmd)
		endif

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


function! base#pathset_db (ref,...)
		let ref = a:ref
		
		let dbfile = base#dbfile()
		
		for [ pathid, path ] in items(ref) 
		
			call pymy#sqlite#insert_hash({
				\	'dbfile' : dbfile,
				\	't'      : 'paths',
				\	'h'      : {
						\	'pathid' : pathid,
						\	'path'   : path,
						\	'pcname' : base#pcname(),
						\	},
				\	'i'      : 'INSERT OR REPLACE',
				\	})
		endfor

		return
endf

function! base#pathset (ref,...)
	let ref = a:ref

  if ! exists("s:paths") | let s:paths={} | endif
	let opts = get(a:000,0,{})


	if exists('g:skip_pathset') 
		return
	endif

	let anew = get(opts,'anew',0)
	let prf = {'func' : 'base#pathset','plugin' : 'base'}

	if anew
		call base#log(['anew=1'],prf)
		let s:paths = {}
	endif

    for [ pathid, path ] in items(ref) 
        let e = { pathid : path }
				call base#log([
					\'pathid ='.pathid,
					\'path   ='.path,
					\	],prf)
        call extend(s:paths,e)
    endfor

    let pathlist = sort(keys(s:paths))
    call base#varset('pathlist',pathlist)

endfun

function! base#split (...)
  let opt = get(a:000,0,'')

  let sub = 'base#split#'.opt
  exe 'call '.sub.'()'
endfun

function! base#append (...)
  let opt = get(a:000,0,'')

	" BaseDatView opts_BaseAppend
	if strlen(opt)
	  let sub = 'base#append#'.opt
	  exe 'call '. sub .'()'
	else
		let opts = base#varget( 'opts_BaseAppend', [])
		let info = []
		call add(info,'Available options for BaseAppend: ')
		call add(info, base#map#add_tabs(opts,1) )
		
		call base#buf#open_split({ 'lines' : info })
	endif

endfunction

function! base#pathlist (...)
		let pat = get(a:000,0,'')

		if ! exists("s:paths")
			let s:paths={}
		endif
		
		let pathlist = sort(keys(s:paths))

		let dbfile = base#dbfile()
		
		let q = 'SELECT pathid FROM paths'

		if strlen(pat)
			let q .= ' WHERE pathid LIKE "%' . pat . '%"'
		endif

		let p = []
		let pathlist = pymy#sqlite#query_as_list({
			\	'dbfile' : dbfile,
			\	'p'      : p,
			\	'q'      : q,
			\	})

		call base#varset('pathlist',pathlist)

    return pathlist
    
endfunction

function! base#paths_from_db ()
	let dbfile = base#dbfile()
	let paths = {}
python << eof
import vim,sqlite3,re

paths = {}
pcname = vim.eval('base#pcname()')

base_dbfile = vim.eval('base#dbfile()')

base_conn = sqlite3.connect(base_dbfile)
base_cur = base_conn.cursor()

q ='''SELECT pathid, path FROM paths WHERE pcname = ?'''
p = [ pcname ] 
base_cur.execute(q,p)

rows = base_cur.fetchall()

for row in rows:
	pathid = row[0]
	path   = row[1]
	paths[pathid] = path
	k = '"' + pathid + '"'
	v = '"' + re.escape(path) + '"'
	cmd = "call extend(paths," + "{" + k + ':' + v + "})"
	vim.command(cmd)

base_conn.commit()
base_conn.close()
	
eof

	if !exists('s:paths')
		let s:paths = {}
	endif
	call extend(s:paths,paths)

	if !exists('g:skip_pathset')
		let g:skip_pathset = 1
	endif

	return paths

endfunction

function! base#paths_update (...)
	let ref = get(a:000,0,{})
	if !exists('s:paths') | let s:paths = {} | endif

	call extend(s:paths,ref)
	call base#pathset_db(ref)

endfunction

function! base#paths_to_db ()
	let dbfile = base#dbfile()
	if !exists('s:paths') | let s:paths = {} | endif

python << eof
import vim,sqlite3

paths = vim.eval('s:paths')
pcname = vim.eval('base#pcname()')

base_dbfile = vim.eval('base#dbfile()')

base_conn = sqlite3.connect(base_dbfile)
base_cur = base_conn.cursor()

for pathid in paths.keys():
	path = paths.get(pathid)
	q ='''INSERT OR IGNORE INTO paths (pathid,path,pcname) VALUES (?,?,?)'''
	p = [ pathid, path, pcname ]
	base_cur.execute(q,p)

base_conn.commit()
base_conn.close()
	
eof

endfunction

function! base#pathid_cwd ()
	let path = getcwd()

	let dbfile = base#dbfile()
	let q      = 'SELECT pathid FROM paths WHERE lower(path) = ? '
	let p      = [ tolower(path) ]

	let pathid = pymy#sqlite#query_fetchone({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})

	return pathid

endfunction

function! base#pathids (path)
    let path = a:path
    let ids  = []

    for id in base#pathlist()
        let rdir = base#file#reldir(path, base#path(id) )
        if strlen(rdir)
            call add(ids, id)
        endif
    endfor

    return ids
endfunction

"""base_path

" base#path('funs')
function! base#path (pathid)
    let prefix='(base#path) '

    if !exists("s:paths")
        call base#init#paths()
    endif

    if exists("s:paths[a:pathid]")
        let path = s:paths[a:pathid]
    else
        let path = ''
				let txt  = "pathid undefined: " . a:pathid 


        call base#warn({ 
            \   "text"   : txt,
            \   "prefix" : prefix ,
            \   })
    endif
    
    return path
    
endfunction

function! base#paths_nice ()
	if !exists("s:paths") | return | endif

  for k in keys(s:paths)
     let s:paths[k]=substitute(s:paths[k],'\/\s*$','','g')
  endfor
	
endfunction

function! base#paths()
	if !exists("s:paths") | return {} | endif

	return s:paths

endfunction

"""base_warn
"
"  base#warn({ "text" : "aaa" })
"  base#warn({ "text" : "aaa", "prefix" : ">>> " })
"
function! base#warn (ref)
		let ref    = a:ref

		let text   = get(ref,'text','')

		let prefix = base#echoprefix()
		let prefix = get(ref,'prefix',prefix)
		let hl     = get(ref,'hl','WarningMsg')
		let rdw     = get(ref,'rdw',0)

		if type(text) == type('')
			let text = prefix . text
		elseif type(text) == type([])
		endif

		if rdw
			redraw!
			exe 'echohl ' . hl
			echo text
			echohl None
		endif

		let prf = {}
		call extend(prf,ref)
		call extend(prf,{ 'loglevel' : 'warn' })

		call base#log(text,prf)
    
endfunction

function! base#time_start ()
	if !exists('g:time_start')
		let	g:time_start = localtime()
	endif

	let time = g:time_start
	let time_s = strftime("%Y %b %d %X",time)

	return time_s

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
   for topic in base#varget('info_topics',[]) 
        call base#info(topic)
   endfor
 else

	 if topic == ''
					 "
"""info_dbext
	 elseif topic == 'dbext'
			call base#info#dbext()

	 elseif topic == 'htmlwork'

"""info__sql
	 elseif topic == '_sql'
			 let lines=[]

			 call add(lines,'Current sql file:')

			 call base#buf#open_split({ 'lines' : lines })
			 return


"""info_dict
	 elseif topic == 'dictionaries'
			 let lines=[]
			 call add(lines,'--------------------')
			 call add(lines,'Dictionaries INFO')
			 call add(lines,'--------------------')
			 call add(lines,'&dictionary:')
			 call extend(lines,base#mapsub(split(&dictionary,','),'^','\t','g'))

			 let vars = base#qw('b:dics b:dicfiles b:dicts')
			 for var in vars
				 if exists(var)
				 		call add(lines,var . ' = ')
						exe 'let dump = base#dump#yaml('.var.')'
						call extend(lines,dump)
				 endif
			 endfor

			 call base#buf#open_split({ 'lines' : lines })
			 return

"""info_datfiles
	 elseif topic == 'datfiles'
			 let lines=[]
			 let dbfile = base#dbfile()

			 let type = input('dattype:','','custom,base#complete#dattypes')
			 
			 let q = 'select keyfull from datfiles where type = ?'
			 let p = [type]
			 
			 let list = pymy#sqlite#query_as_list({
			 	\	'dbfile' : dbfile,
			 	\	'p'      : p,
			 	\	'q'      : q,
			 	\	})
			 call base#buf#open_split({ 'lines' : list })

	 elseif topic == 'datfiles_dict'

"""info_file
	 elseif topic == 'file'
			call base#buf#start()

			let info = []

			call add(info,'General Info:')
			let info_g = [
			\ [ '(cwd)  dir   :', getcwd() ],
			\ [ '(cwd)  pathid:', base#pathid_cwd() ],
			\ ]

			let lines = pymy#data#tabulate({ 
				\	'data'    : info_g,
				\	'headers' : [],
				\	})
			call extend(info,base#map#add_tabs(lines,1))

			call extend(info,['FILE INFO:'])
			
			let info_a = [
			\ [ 'Current file:', expand('%:p') ],
			\ [ 'File directory (dirname):', expand('%:p:h') ],
			\ [ 'Filetype:', &ft ],
			\ [ 'Filesize:', base#file#size(b:file) ],
			\ ]

			let lines = pymy#data#tabulate({ 
				\	'data'    : info_a ,
				\	'headers' : [],
				\	})
			call extend(info,base#map#add_tabs(lines,1))

			call add(info,'Other variables:')
			let info_other = []

			let var_names  = base#qw("b:basename b:dirname b:file b:ext b:bufnr")

			for var_name in var_names
				let var_value = exists(var_name) ? eval(var_name) : ''

				call add(info_other,[ var_name, var_value ])
			endfor

			let lines = pymy#data#tabulate({ 
				\	'data'    : info_other,
				\	'headers' : [],
				\	})
			call extend(info,base#map#add_tabs(lines,1))

			call add(info,'Directories which this file belongs to:')
			let dirs_belong = base#buf#pathids_str()
			call add(info,indent . dirs_belong)

			if exists("b:other")
				call add(info,'OTHER INFO:')
				let y = base#dump#yaml(b:other)
				let y = base#map#add_tabs(y)
				call extend(info,y)
			endif

			if exists("b:aucmds")
				call add(info,'AUTOCOMMANDS:')
				call add(info,"\t".'b:aucmds:')
				let y = base#dump#yaml(b:aucmds)
				let y = base#map#add_tabs(y,2)
				call extend(info,y)

				if exists("b:augroup")
					call add(info,"\t".'b:augroup:')
					let y = base#dump#yaml(b:augroup)
					let y = base#map#add_tabs(y,2)
					call extend(info,y)
				endif
			endif

			if exists("b:html_info")
				call add(info,'HTML INFO:')
				let y = base#dump#yaml(b:html_info)
				let y = base#map#add_tabs(y)
				call extend(info,y)

			endif

			if exists("b:db_info")
					
				call add(info,'DB INFO:')
				let y = base#dump#yaml(b:db_info)
				let y = base#map#add_tabs(y)
				call extend(info,y)
			endif

			call base#buf#open_split({ 'lines' : info })

"""info_perlapp
   elseif topic == 'perlapp'
       call base#echo({ 'text' : "PerlApp options: " } )
       call base#varecho('perlmy_perlapp_opts')

"""info_leaders
   elseif topic == 'leaders'
       call base#echo({ 'text' : "Leader variables: " } )

			 let lines=[]
       call add(lines,'mapleader:        ' . base#vimvar#get('g:mapleader') )
       call add(lines,'maplocalleader:   ' . base#vimvar#get('g:maplocalleader') )

			 for line in lines
			 		call base#echo({ 'text' : line })
			 endfor

   elseif topic == 'snippets'
			 let lines=[]
			 call add(lines,'--------------------')
			 call add(lines,'Snippets INFO')
			 call add(lines,'--------------------')
			 call add(lines,'g:snippets_dir:')
			 call extend(lines,base#mapsub(split(g:snippets_dir,','),'^','\t','g'))

			 call base#buf#open_split({ 'lines' : lines })
			 return
           
"""info_git
   elseif topic == 'git'
       call base#echo({ 'text' : "Git: " } )

       call base#varecho('gitinfo')

"""info_grep
   elseif topic == 'grep'
				let lines = []

			 	call add(lines,'--------------------')
				call add(lines,'GREP INFO')
			 	call add(lines,'--------------------')
				call add(lines,'&grepprg:')
				call add(lines,'  '.&grepprg)
				call add(lines,'&grepformat:')
				call add(lines,'  '.&grepformat)
				call add(lines,'base#grepopt():')
				call add(lines,'  ' . base#grepopt() )

			 call base#buf#open_split({ 'lines' : lines })
			 return

"""info_java
   elseif topic == 'java'
      if base#plg#loaded('my_java')
          call my_java#act#info()
      endif

"""info_sqlite
   elseif topic == 'sqlite'
			call base#sqlite#info()

   elseif topic == 'sqlite_prompt'
			call base#sqlite#info({ 'prompt' : 1 })

   elseif topic == 'sqlite_sql'
			call base#sqlite#info_sql()

"""info_bufs
   elseif topic == 'bufs'

			 let info = []
       call add(info," " )
       call add(info,"Buffer-related stuff: " )
       call add(info," " )
       call add(info," BYFF     - buffer-related command" )
       call add(info," " )
       call add(info," --- current buffer --- " )
       call add(info," " )

       let ex_finfo = exists('b:finfo')
       let ex_bbs   = exists('b:base_buf_started')

       call add(info," b:finfo exists => " . ex_finfo   )
       call add(info," b:base_buf_started exists => " . ex_bbs   )

       if ex_finfo
            call add(info," b:finfo  => " )
						call add(info,  pymy#var#pp( b:finfo ) )
       endif

       call add(info," "   )

       let pathids =  base#buf#pathids ()
       call add(info," pathids => " . join(pathids,' ')   )

			 call base#buf#open_split({ 'lines' : info })

"""info_vars
   elseif topic == 'vars'
			let regex = input('regex: ','')
			let varlist = base#vim#varlist({ 'regex' : regex })
			call base#buf#open_split({ 'lines' : varlist })

"""info_tagbar
   elseif topic == 'plg_tagbar'
			 	let info = []
				call add(info,'Tagbar Plugin Info:')

        let vars = base#varget('tagbar_vars',[])
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

		let stl    = base#varget('stl','')
		let stlopt = base#varget('stlopt','')
		
		let d = base#delim()
		let info = []
		call add(info,d)
		call add(info,'Statusline Info')
		call add(info,d)
		call add(info,'BaseVarEcho stlopt:')
		call add(info,"\t" . stlopt )
		call add(info,'BaseVarEcho stl:')
		call add(info,"\t" . stl )
		call add(info,'&stl:')
		call add(info,"\t" . &stl )
		call add(info,' ')
		
		call base#buf#open_split({ 'lines' : info })

"""info_paths
   elseif topic == 'paths'
			 let paths = base#pathlist()

			 let info = []
			 call add(info,'PATHS: ')
			 call add(info,base#map#add_tabs(sort(paths),1))

			 call base#buf#open_split({ 'lines' : info })

"""info_dirs
   elseif topic == 'dirs'

       call base#echo({ 'text'   : "Directory-related variables: " } )
       call base#echovar({ 'var' : 'g:dirs', 'indent' : indentlev })

"""info_env
   elseif topic == 'env'
     call base#echo({ 'text' : "ENVIRONMENT ", 'hl' : 'Title' } )

     let evlist = base#envvarlist()
		 let evlist_t = base#map#add_tabs(evlist)

		 let info_env = []
		 call add(info_env,'To see the value of specific env. variable, use:')
		 let envcmds=[
		 		\	'BaseAct envvar_open_split',
		 		\	'BaseAppend env_path',
		 		\	'BaseAppend envvar',
		 		\	]
		 call extend(info_env,base#map#add_tabs(envcmds))

		 call add(info_env,'List of Environment Variables:')
		 call extend(info_env,evlist_t)

		 call base#buf#open_split({ 'lines' : info_env })

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
			let tags = split(&tags,",")
			
			let tgs = base#tg#ids_comma()
			let tgids = split(tgs,',')

			let info = []

			call add(info, "Tag ID: ")
			for tgid in tgids 
				call add(info," " . tgid)
			endfor
			
			call add(info,'Tags: ')
			call add(info," &tags => ")

			for t in tags
				call add(info,"\t" . t )
			endfor

			call base#buf#open_split({ 'lines' : info })

"""info_perl
   elseif topic == 'perl'
			call perlmy#info()

"""info_python
   elseif topic == 'python'
			PYMY info

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
      let rtp_a = split(&rtp,",")

			let ii = []
			call add(ii,'&rtp:')
			call extend(ii,base#map#add_tabs(rtp_a,1))

			call base#buf#open_split({ 'lines' : ii })

"""info_plugins
   elseif topic == 'plugins'
			let plugins = base#plugins()

			let ii = []
			call add(ii,'PLUGINS:')
			call extend(ii,base#map#add_tabs(plugins,1))
			call base#buf#open_split({ 'lines' : ii })

"""info_make
   elseif topic == 'make'
			
			let info = []
			call add(info,'MAKE:')
			
			let info_a = [
			\ [ 'cwd', getcwd() ],
			\ [ '&makeprg', &makeprg ],
			\ [ '&efm', &efm ],
			\ [ '&makeef:', &makeef ],
			\ [ 'makeprg id', make#varget('makeprg','') ],
			\ [ 'efm id', make#varget('efm','') ],
			\ ]

			for x in info_a
				 call add(info,get(x,0,''))
				 call add(info,indent . get(x,1,''))
			endfor

			call base#buf#open_split({ 'lines' : info })

"""info_opts
   elseif topic == 'opts'

			 let ii = [] 
			 let opts = base#varget('opts',{})
			 let li = base#dump#dict_tabbed (opts)

			 call add(ii,'OPTIONS: ')
			 call extend(ii,li)
			 call base#buf#open_split({ 'lines' : li })


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
		let plgdir = $VIMRUNTIME . '/plg/base' 
		call base#varset('plgdir',plgdir)
		return plgdir
endf    

"" let dd = base#datadir()
"" call base#datadir('aaa')

function! base#datadir (...)
    if a:0
        let datadir = a:1
        return base#varset('datadir',datadir)
    endif

    return base#varget('datadir','')
endf    

function! base#delim (...)
	 let d = '-'
	 let num = 70
	 return repeat(d,num)
endf    

" go to base plugin root directory

function! base#plgcd ()
    let dir = base#plgdir()
    exe 'cd ' . dir
endf    

function! base#envvar_a (varname,...)
	if has('win32')
		let sep =';'
	else
		let sep =':'
	endif
	let sep = get(a:000,0,sep)

	let var = base#envvar(a:varname)
	let a = split(var,sep)

	return a

endf    


function! base#envvar_open_split (varname, ... )
	let a = base#envvar_a(a:varname)
	call base#buf#open_split({'lines' : a})

endf    

function! base#envvar (varname, ... )
		let default = get(a:000,0,'')

    let var  = '$' . a:varname
    let val  = default

		if has('perl')
perl << eof
	use Vim::Perl qw(VimLet VimEval);

	my $default = VimEval('default');
	my $env = sub { my $vname = shift; $ENV{$vname} || $default; };

	my $varname = VimEval('a:varname');
	my $val     = $env->($varname);

	if($^O eq 'MSWin32'){
		local $_ = $val;
		while(/%(\w+)%/){
			my $vname = $1;
			my $vval  = $env->($vname);
			s/%(\w+)%/$vval/g;
		}
		$val=$_;
	}

	VimLet('val',$val);
eof
		else
	    if exists(var)
	        exe 'let val = ' . var
	    endif
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
    let val =  base#varget(a:varname)

    let ref = { 'text' : a:varname .' => '. base#dump(val), 'prefix' : '' }
    if a:0
        if base#type(a:1) == 'Dictionary'
            call extend(ref,a:1)
        endif
    endif
    call base#echo(ref)

endfunction

function! base#dump_split (...)
	let val = get(a:000,0,'')
	let dump = base#dump(val)
	return split(dump,"\n")
endfunction

function! base#dump (...)
    let val  = a:1
    let dump = ''

		try
			let dump = prettyprint#prettyprint(val)
		catch
		endtry

    return dump
endfunction

function! base#varget_nz (varname,...)

    if ! exists("s:basevars") | let s:basevars = {} | endif
    
    if exists("s:basevars[a:varname]")
      let l:val = copy( s:basevars[a:varname] )
		endif

		"" var already exists and is non zero
		if exists("l:val") 
			if ( type(l:val) == type("") && strlen(l:val) )
				return l:val

			elseif ( type(l:val) == type([]) && len(l:val) )
				return l:val

			elseif ( type(l:val) == type({}) && len(l:val) )
				return l:val

			endif
		endif

		let l:val = ''
		if a:0
			let default = a:1
			unlet l:val | let l:val = default
		endif

		return l:val
    
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


function! base#vars()

    if ! exists("s:basevars")
        let s:basevars={}
    endif

		return s:basevars

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
    let varname = get(a:000,0,'')
		let type    = get(a:000,1,'List')

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
		let id = a:id

    let files = base#datafiles(a:id)
    let file  = get(files,0,'')
    return file
endfunction

function! base#plugins (...)
		let plugins = []
		let dbfile = base#dbfile()
		
		let q = 'select plugin from plugins'
		let p = []
		
		let plugins = pymy#sqlite#query_as_list({
			\	'dbfile' : dbfile,
			\	'p'      : p,
			\	'q'      : q,
			\	})
		return plugins

endfunction

function! base#plugins_all (...)
		let dbfile = base#dbfile()
		
		let q = 'select plugin from plugins_all'
		let p = []
		
		let plugins_all = pymy#sqlite#query_as_list({
			\	'dbfile' : dbfile,
			\	'p'      : p,
			\	'q'      : q,
			\	})
		return plugins_all

endfunction

function! base#datafiles (...)
		let id  = get(a:000,0,'')
		let ref = get(a:000,1,{})

		return base#sqlite#datfiles(id,ref)

    "let datadir = base#datadir()
    "let file    = a:id . ".i.dat"

		"let pat   = '^'.file.'$'
    "let files = base#find({
        "\ "dirs"    : [ datadir ],
        "\ "subdirs" : 1,
        "\ "pat"     : pat,
        "\  })

    return files

endfunction

function! base#datlist (...)
	let ref = get(a:000,0,{})

	let dfiles = base#datafiles('',ref)
	let list = sort(keys(dfiles))
	return list
endfunction

function! base#initvarsfromdat ()
		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		let msg = ['start']
		let prf = { 'func' : 'base#initvarsfromdat', 'plugin' : 'base'}
		call base#log(msg,prf)
		let l:start=localtime()
		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    let dattypes = base#qw("list listlines dict")
		let mp = { 
			\	"list"      : "List",
			\	"dict"      : "Dictionary",
			\	"listlines" : "ListLines",
			\	}
		for type in dattypes
        let tp = get(mp,type,'')
				let dlist = base#datlist({'type' : type })
				for v in dlist
        	call base#varsetfromdat(v,tp)
				endfor
		endfor
		
		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		let l:elapsed = localtime() - l:start
		let msg = ['end, elapsed = ' . l:elapsed]
		let prf = {'plugin' : 'base', 'func' : 'base#initvarsfromdat'}
		call base#log(msg,prf)
		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
endfunction

function! base#initvarsfromdat_vim ()
		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		let msg = ['start']
		let prf = { 'func' : 'base#initvarsfromdat_vim', 'plugin' : 'base'}
		call base#log(msg,prf)
		let l:start=localtime()
		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    let refdef = {}
    let ref    = refdef
    let refa   = get(a:000,0,{})

    call extend(ref,refa)

    let datfiles = base#datafiles()
    let datlist  = base#datlist()

    let dir = base#datadir()
    let dir = get(ref,'dir',dir)

    let mp = { 
			\	"list"      : "List",
			\	"dict"      : "Dictionary",
			\	"listlines" : "ListLines",
			\	}
    for type in base#qw("list listlines dict")
        let dir = base#file#catfile([ base#datadir(), type ])
        let vars= base#find({ 
            \   "dirs"    : [ dir ],
            \   "exts"    : [ "i.dat" ],
            \   "subdirs" : 1,
            \   "rmext"   : 1, })
				let vars = map(vars,'base#file#reldir(v:val,dir)')

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

		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		let l:elapsed = localtime() - l:start
		let msg = ['end, elapsed = ' . l:elapsed]
		let prf = {'plugin' : 'base', 'func' : 'base#initvarsfromdat_vim'}
		call base#log(msg,prf)
		"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    
endfunction


function! base#varlist ()
    let varlist = keys(s:basevars)
    call base#varset('varlist',varlist)
    return varlist
endfunction

function! base#where (file)
	if base#noperl() | return | endif

	let paths=[]
perl << eof
	use File::Which qw(where);
	my $file=VimVar('a:file');

	my @paths=where($file);
	VimListExtend('paths',[@paths]);
eof
	return paths

endfunction

function! base#act (...)
  let act = get(a:000,0,'')

	if ! strlen(act) 
		let comps_n = base#complete#BaseAct()
		let comps   = split(comps_n,"\n")

		let act = base#getfromchoosedialog({ 
						\ 'list'        : comps,
						\ 'startopt'    : get(comps,0,''),
						\ 'header'      : "Available BaseAct commands are: ",
						\ 'numcols'     : 2,
						\ 'bottom'      : "Choose BaseAct command by number: ",
						\ })
	endif

	if act =~ '^sqlite_'
		let cmd = substitute(act,'^sqlite_\(.*\)$','\1','g')
  	let sub = 'base#sqlite#' . cmd

	elseif act =~ '^svn_'
		let cmd = substitute(act,'^svn_\(.*\)$','\1','g')
  	let sub = 'base#svn#' . cmd

	else
  	let sub = 'base#act#' . act
	endif

  exe 'call ' . sub . '()'

endf    

function! base#pcname()
	let pc  = (has('win32')) ? base#envvar('COMPUTERNAME') : get(split(system('hostname'),"\n"),0)
	return pc
endf    

function! base#username()
	let pc  = (has('win32')) ? base#envvar('USER') : base#envvar('USER')
	return pc
endf    

function! base#home()
	let pc  = (has('win32')) ? base#envvar('USERPROFILE') : base#envvar('HOME')
	return pc
endf  


function! base#init (...)

	let dat_inor = base#file#catfile([  base#plgdir() , 'data', 'list', 'init_order.i.dat' ])
	let opts = base#readarr(dat_inor) 
	call base#varset('init_order',opts)

	let dat_all = base#file#catfile([  base#plgdir() , 'data', 'list', 'all_init_cmds.i.dat' ])
	let opts_all = base#readarr(dat_all) 
	call base#varset('all_init_cmds',opts_all)

	let prf = { 'func' : 'base#init', 'plugin' : 'base'}
 
  if a:0
    let ref = get(a:000,0,'')

		if type(ref)==type('')
				let opt = ref
				let msg = 'init opt = ' .  opt
				call base#log(msg,prf)

		elseif type(ref)==type([])
				let opts = ref
				for opt in opts
					call base#init(opt)
				endfor
				return
		endif

		if	!base#inlist(opt,opts_all)
			echohl WarningMsg
			echo 'wrong opt for base#init(): ' . opt
			echohl None
			return
		endif

    if opt == 'cmds'
        call base#init#cmds()

    elseif opt == 'au'
        call base#init#au()

    elseif opt == 'sqlite'
        call base#init#sqlite({ 'reload' : 1})

    elseif opt == 'files'
        call base#init#files()

    elseif opt == 'paths'
        call base#init#paths()

    elseif opt == 'vars'
        call base#init#vars()

    elseif opt == 'plugins'
        call base#init#plugins()

    elseif opt == 'tagids'
        call base#init#tagids()

    elseif opt == 'menus'
        call base#menus#init()

    elseif opt == 'stl'
        call base#stl#setparts()

    elseif opt == 'env'
        call base#env#init()

    elseif opt == 'paths_apoplavskiynb'
        call base#initpaths#apoplavskiynb()

    elseif opt == 'omni'
        call base#omni#init()

    elseif opt == 'rtp'
  		call base#rtp#update()
    endif
    return
  endif

  call base#init(opts)

  call base#stl#setlines()
    
  return 1

endfunction

function! base#mkdir (dir)

  if isdirectory(a:dir)
    return  1
  endif

  try
    call mkdir(a:dir,'p')
    call base#log([
				\ 'base#mkdir created directory:',
				\ 'base#mkdir '. a:dir])
  catch
    call base#warn({ "text" : "Failure to create dir: " . a:dir})
  endtry

endf


function! base#viewdat (...)
            
  if a:0
    let dat=a:1
  else
    let dat=base#getfromchoosedialog({ 
        \ 'list'        : base#datlist(),
        \ 'startopt'    : '',
        \ 'header'      : "Available DAT files are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose DAT file by number: ",
        \ })
  endif

  let datfile = base#datafiles(dat)

  call base#fileopen(datfile)
endf
 
"
"   base#listnewinc(start,end,inc)
"

function! base#listnewinc(start,end,inc)

 let a=[]

 let i=0
 let counter=a:start

 if a:inc > 0
	 while counter < a:end+1
	   call add(a,counter)
	
	   let counter+=a:inc
	   let i+=1
	 endw
 else
	 while counter > a:end-1
	   call add(a,counter)
	
	   let counter+=a:inc
	   let i+=1
	 endw
 endif

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
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'grep' })
"call base#grep({ "pat" : pat, "files" : files, "opt" : 'vimgrep' }) -todo

function! base#grep (...)
    let ref = {}
    if a:0 | let ref = a:1 | endif

		let opt = base#grepopt()

    let pat   = get(ref,'pat','')
    let files = get(ref,'files',[])
    let opt   = get(ref,'opt',opt)

		let grepprg = get(ref,'grepprg','')

    let rootdir = get(ref,'rootdir','')

    if strlen(rootdir)
        call map(files,'base#file#catfile([ rootdir, v:val ])')
    endif

    let cd_to_dir = get(ref,'cd_to_dir','')
		if strlen(cd_to_dir) 
			if !isdirectory(cd_to_dir)
				call base#mkdir(cd_to_dir)
			endif

			call base#cd(cd_to_dir)
		endif

    call map(files,'base#file#win2unix(v:val)')

		let cmds = []

    if opt == 'plg_findstr'

        let gref = {
            \  "files"        : files          ,
            \  "pat"          : pat            ,
            \  "cmd_name"     : 'Rfindpattern' ,
            \  "findstr_opt"  : '/i'           ,
            \  "cmd_opt"      : '/R /S'        ,
            \  "use_startdir" : 0              ,
            \}

        call add(cmds,'call findstr#ap#run(gref)')

    elseif opt == 'vimgrep'
        call add(cmds, 'vimgrep /'.pat.'/ '. join(files,' ') )

    elseif opt == 'grep'
				let patq = "'".pat."'"
				let a    = []

				"if strlen(grepprg)
					"call add(cmds,'let &grepprg='."'".escape(grepprg,' ')."'")
				"endif

				let q ="'"

				call add(cmds, 'call setqflist([])' )
				for f in files
					let a=[]
					call extend(a,['silent grepadd!',patq])
					call extend(a,[f])
	   			let cmd = join(a,' ')
					call add(cmds, cmd )
				endfor

    endif

		for cmd in cmds
			let cmde = strpart(cmd,0,50)
			exe cmd
		endfor

		let matches = len(getqflist())

		redraw!
		if matches
			echohl MoreMsg
			echo 'base#grep() has found ' . matches . ' matches'
			echohl None
			copen
		else
			echohl DiffText
			echo 'base#grep() has found no matches '
			echohl None
		endif

		return 1
    
endfunction


function! base#grepopt (...)
    if ! base#varexists('grepopt')
        if has('win32')
            let opt = 'plg_findstr'
            let opt = 'grep'
        else
            let opt = 'grep'
        endif
    else
        let opt = base#varget('grepopt','')
    endif

    if a:0 | let opt = a:1 | endif

		let opt = 'grep'
    call base#varset('grepopt',opt)

    "return base#varget('grepopt','')
    return opt
endfunction

function! base#envvarlist ()
    call base#envvars()
    let evlist = base#varget('evlist',[])

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
     call base#varset('ev',ev)
     call base#varset('evlist',evlist)

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
 


