

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

fun! base#viewvimfunc(fun)
 
  let fun=a:fun

  let fun=substitute(fun,'\s*$','','g')
  let fun=substitute(fun,'^\s*','','g')

  let fundir=g:dirs.funs

  let funfile=fundir . '/' . fun . '.vim'

  exe 'edit ' . funfile
  
endfun

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


fun! base#loadvimcommand(com)

  let com=a:com

  let com=substitute(com,'\s*$','','g')
  let com=substitute(com,'^\s*','','g')

  let comdir=g:dirs.coms

  let comfile=comdir . '/' . com . '.vim'

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

function! base#varupdate (varname)

	call ap#Vars#set(a:varname)
	
endfunction
 
fun! base#varcheckexist(ref)

 if base#vartype(a:ref) == 'String'
   let varname=a:ref
   
 elseif base#vartype(a:ref) == 'List'
   let vars=a:ref
   for varname in vars
     call base#varcheckexist(varname)
   endfor

   return
 endif

 let varname=substitute(varname,'^\(g:\)*','g:','g')

 if ! exists(varname)
     call ap#varupdate(varname)
 endif
 
endfun
 
