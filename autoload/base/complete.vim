
"""base_complete_vimfuns
function! base#complete#vimfuns (...)
  
  return base#complete#vars([ 'vim_funcs_user' ])
 
endfun

function! base#complete#vimcoms (...)
  
  return base#complete#vars([ 'vim_coms' ])
 
endfun

function! base#complete#CD (...)

  return base#complete#vars([ 'pathlist' ])
	
endfunction

function! base#complete#info (...)

  return base#complete#vars([ 'info_topics' ])
	
endfunction

function! base#complete#varlist (...)

  return base#complete#vars([ 'varlist' ])
	
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
 
