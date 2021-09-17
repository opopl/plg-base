


function! base#x#list (...)
  let expr = get(a:000,0,{})
  let opts = get(a:000,1,{})

  let sep = get(opts,'sep',' ')

  if base#type(expr) == 'String'
    
  elseif base#type(expr) == 'List'
    
  
  elseif base#type(expr) == 'Number'
  
  elseif base#type(expr) == 'Float'
    
  elseif base#type(expr) == 'Dictionary'
    
    
  endif
  
endfunction
