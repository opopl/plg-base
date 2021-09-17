
function! base#x#list (...)
  let expr = get(a:000,0,{})
  let opts = get(a:000,1,{})

  let sep = get(opts,'sep',' ')

  let lst = []
  let tp = base#type(expr)

  let r = { 'sep' : sep }
  if tp  == 'String'
    let lst = base#string#split_trim(expr,r)
    
  elseif base#inlist(tp,base#qw('Number Float'))
    let expr = string(expr)
    let lst = base#x#list(expr,opts)

  elseif tp == 'List'
    let lst = expr

  elseif tp == 'Dictionary'
    
  endif
  return lst
  
endfunction
