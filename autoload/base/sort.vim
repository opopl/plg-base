
function! base#sort#compare_nums_ascend (i1,i2)
   return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunction

function! base#sort#compare_nums_descend (i1,i2)
   return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? -1 : 1
endfunction

function! base#sort#num_ascend (arr)
  let arr = copy(a:arr)
  let arr = sort(arr,'base#sort#compare_nums_ascend')
  return arr
endfunction

function! base#sort#num_descend (arr)
  let arr = copy(a:arr)
  let arr = sort(arr,'base#sort#compare_nums_descend')
  return arr
endfunction
