
fun! base#globalvars#loadfromdat(dat)

  let varvals=F_ReadDictDat(a:dat)
  for [k,v] in items(varvals)
    let g:{k}=v
  endfor

  let vars=[
    \ 'colorscheme',
    \ ]

  for varname in vars
	  if exists('g:' . varname)
      if varname == 'colorscheme'
	     exe 'colorscheme ' . g:{varname} 
	    endif
	  endif
  endfor
  
endf
