
function! base#string#matchlist (string,pattern)
   let a = matchlist(a:string,a:pattern)
   if len(a)
      call remove(a,0)
   endif
   return a
endfunction
