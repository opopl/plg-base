
"""base_complete_vimcommands
function! base#complete#vimcommands (...)
  
  return base#complete#custom([ 'VimCommands' ])
 
endfun

"""base_complete_vimfuns
function! base#complete#vimfuns (...)
  
  return base#complete#custom([ 'vim_funcs_user' ])
 
endfun

function! base#complete#info (...)

  return base#complete#vars([ 'info_topics' ])
	
endfunction

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

 let comps=base#uniq(sort(comps))

 return join(comps,"\n")
 
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
    call extend(comps,base#var(varname))
  endfor

 let comps=base#uniq(sort(comps))

 return join(comps,"\n")
 
endfunction
 
