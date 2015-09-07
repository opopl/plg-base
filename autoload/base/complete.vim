
function! base#complete#vimcommands (...)
  
  return base#complete#custom([ 'VimCommands' ])
 
endfun

function! base#complete#vimfuns (...)
  
  return base#complete#custom([ 'vim_funcs_user' ])
 
endfun
 

function! base#complete#custom (...)

 LFUN F_uniq
 LFUN F_VarCheckExist

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
  
    call F_VarCheckExist(varname)
    call extend(comps,{varname})

  endfor

 let comps=F_uniq(sort(comps))

 return join(comps,"\n")
 
endfunction
 
