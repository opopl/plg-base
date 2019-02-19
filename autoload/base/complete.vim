
"""base_complete_vimfuns
function! base#complete#vimfuns (...)
  return base#complete#vars([ 'vim_funcs_user' ])
endfun

function! base#complete#gitcmds (...)
  return base#complete#vars([ 'gitcmds' ])
endfun

function! base#complete#envcmd (...)
  return base#complete#vars([ 'envcmds' ])
endfun

function! base#complete#powershell (...)
  return base#complete#vars([ 'cmds_powershell' ])
endfun

function! base#complete#psopts (...)
  return base#complete#vars([ 'psopts' ])
endfun

function! base#complete#vimcoms (...)
  return base#complete#vars([ 'vim_coms' ])
endfun

function! base#complete#exefileids (...)
  return base#complete#vars([ 'exefileids' ])
endfun

function! base#complete#fileadd(...)
  return base#complete#vars([ 'opts_FileAdd' ])
endfun

function! base#complete#CD (...)
  return base#complete#vars([ 'pathlist' ])
endfunction

function! base#complete#DIR (...)
	let opts = base#varget('opts_DIR',[])
	let more = []

	call extend(more,opts)

  return base#complete#vars([ 'pathlist' ],{'addmore' : more })
endfunction

function! base#complete#sync (...)
  return base#complete#vars([ 'opts_Sync' ])
endfunction


function! base#complete#paplist (...)
  return base#complete#vars([ 'paplist' ])
endfunction

function! base#complete#menus (...)
  return base#complete#vars([ 'menus' ])
endfunction

function! base#complete#init (...)
  return base#complete#vars([ 'base_init_cmds' ])
endfunction

function! base#complete#opts (...)
  return base#complete#vars([ 'opts_keys' ])
endfunction

function! base#complete#plgact(...)
    return base#complete#vars([ 'plgact' ])
endf

function! base#complete#plg(...)
    return base#complete#vars([ 'plugins_all' ])
endf

function! base#complete#plg_with_all(...)
    return base#complete#vars([ 'plugins_all' ],{ 'addmore' : ['_all_'] })
endf

function! base#complete#BaseAppend (...)
  return base#complete#vars([ 'opts_BaseAppend' ])
endfunction

function! base#complete#perl_Vim_Plg_Base(...)
  return base#complete#vars([ 'opts_perl_Vim_Plg_Base' ])
endfunction

function! base#complete#BaseAct (...)
  return base#complete#vars([ 'opts_BaseAct' ])
endfunction

function! base#complete#grep_history (...)
  return base#complete#vars([ 'grep_history' ])
endfunction

function! base#complete#BufAct (...)
	let comps = []
	if exists("b:comps_BufAct")
		let comps = b:comps_BufAct
	endif
	return join(comps,"\n")
endfunction

function! base#complete#sqlite_dbfiles (...)
	let dbfiles = base#sqlite#dbfiles()

	let comps = sort(keys(dbfiles))
	return join(comps,"\n")

endfunction

function! base#complete#sqlite_tables (...)
	let tables = base#sqlite#tables()

	let comps = sort(tables)
	return join(comps,"\n")
endfunction

function! base#complete#sqlite_sql (...)
  return base#complete#vars([ 'sqlite_sql' ])
endfunction

function! base#complete#sqlite_sql_opt_print (...)
  return base#complete#vars([ 'sqlite_sql_opt_print' ])
endfunction

function! base#complete#imageact (...)
  return base#complete#vars([ 'opts_ImageAct' ])
endfunction

function! base#complete#baselog (...)
  return base#complete#vars([ 'baselog_cmds' ])
endfunction

function! base#complete#basesys (...)
  return base#complete#vars([ 'hist_basesys' ])
endfunction

function! base#complete#FIND (...)
  return base#complete#vars([ 'opts_FIND' ])
endfunction

function! base#complete#info (...)
  return base#complete#vars([ 'info_topics' ])
endfunction

"function! base#complete#fetch (...)
  "return base#complete#vars([ 'inf' ])
"endfunction

function! base#complete#tagids (...)
  return base#complete#vars([ 'tagids' ])
endfunction

function! base#complete#VH (...)
  return base#complete#vars([ 'opts_VH' ])
endfunction

function! base#complete#varlist (...)
  call base#varlist()

  return base#complete#vars([ 'varlist' ])
	
endfunction

function! base#complete#varlist_list (...)
	 let varlist      = base#varget('varlist',[])
	 let varlist_list = filter(varlist,'type(base#varget(v:val)) == type([])')

	 call base#varset('varlist_list',varlist_list)

 	 return base#complete#vars([ 'varlist_list' ])

endfunction

function! base#complete#datlist (...)
  return base#complete#vars([ 'datlist' ])
endfunction

function! base#complete#idat_acts (...)
  return base#complete#vars([ 'idat_acts' ])
endfunction

function! base#complete#statuslines (...)
  call base#stl#setlines()
  return base#complete#vars([ 'stlkeys' ])
endfun

function! base#complete#keymap (...)

  let comps = []
  return join(sort(comps),"\n")

endfun

"""base_complete_vimfuns
function! base#complete#custom (...)

 let comps=[]

 if a:0
   if type(a:1) == type([])
     let vars=a:1

   elseif type(a:1) == type('')
     let vars=[ a:1 ] 

   endif
 endif

  for varname in vars
    let varname=substitute(varname, '^\(g:\)*' , 'g:' , 'g' )
  
    call base#varcheckexist(varname)
    call extend(comps,{varname})

  endfor

 let comps = base#uniq(sort(comps))

 return join(comps,"\n")
 
endfunction

function! base#complete#envvarlist (...)
  call base#envvars()

  return base#complete#vars([ 'envvarlist' ])

endfunction

function! base#complete#dattypes (...)
 let comps = base#qwsort('list dict')

 return join(comps,"\n")
endfunction

"call base#complete#vars ([varname])
"
" for PlgAct:
"call base#complete#vars ([plugins_all],{ 'addmore' : ['_all_']})

function! base#complete#vars (...)

 let comps = []
 let vars  = get(a:000,0,[])

 let ref     = get(a:000,1,{})
 let addmore = get(ref,'addmore',[])

 for varname in vars
		let val = base#varget(varname,[])
		call extend(comps,val)
 endfor

 call extend(comps,addmore)

 let comps=base#uniq(sort(comps))

 return join(comps,"\n")
 
endfunction

function! base#complete#omnioptions (...)
  return base#complete#vars([ 'omni_compoptions_list' ])
endfunction

