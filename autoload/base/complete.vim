
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

function! base#complete#vimcoms (...)
  
  return base#complete#vars([ 'vim_coms' ])
 
endfun

function! base#complete#CD (...)
  return base#complete#vars([ 'pathlist' ])
endfunction

function! base#complete#paplist (...)
  return base#complete#vars([ 'paplist' ])
endfunction

function! base#complete#info (...)

  return base#complete#vars([ 'info_topics' ])
	
endfunction

function! base#complete#tagids (...)
  return base#complete#vars([ 'tagids' ])
endfunction

function! base#complete#varlist (...)
  call base#varlist()

  return base#complete#vars([ 'varlist' ])
	
endfunction

function! base#complete#datlist (...)

  return base#complete#vars([ 'datlist' ])
	
endfunction

function! base#complete#statuslines (...)
 
  call base#stl#setlines()
  let comps = keys(g:F_StatusLines)
  call add(comps,'ap')

  let comps = base#uniq(comps)

  return join(sort(comps),"\n")
 
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

function! base#complete#vars (...)

 let comps=[]

 if a:0
   if type(a:1) == type([])
     let vars=a:1

   elseif type(a:1) == type('')
     let vars=[ a:1 ] 

   endif
 endif

  for varname in vars
	let val = base#var(varname)
	if base#type(val) == 'List'
    	call extend(comps,val)
	endif
  endfor

 let comps=base#uniq(sort(comps))

 return join(comps,"\n")
 
endfunction

function! base#complete#omnioptions (...)
  return base#complete#vars([ 'omni_compoptions_list' ])
endfunction

