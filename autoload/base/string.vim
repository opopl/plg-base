
function! base#string#matchlist (string,pattern)
   let a = matchlist(a:string,a:pattern)
   if len(a)
      call remove(a,0)
   endif
   return a
endfunction

function! base#string#qq (string)
	return '"'.a:string.'"'
endfunction

function! base#string#quote (string)
	return '"'.a:string.'"'
endfunction
