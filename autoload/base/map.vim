
function! base#map#fnamemodify (arr,mods)
  let arr  = copy(a:arr)
  let mods = a:mods

  call map(arr,'fnamemodify(v:val,mods)')

  return arr
endfunction

function! base#map#trim (arr,...)
  let arr  = copy(a:arr)
  call map(arr,"base#trim(v:val)")
  return arr
endfunction

function! base#map#filter (arr,...)
  let arr  = copy(a:arr)

  let ref = {
    \ 'regex' : '',
    \ }
  let ref   = extend(ref, get(a:000,0,{}) )
  let regex = get(ref,'regex','')

  if strlen(regex)
    call filter(arr,"strlen(matchstr(v:val, regex))")
  endif
  return arr

endfunction

"add one tab 
"   call base#map#add_tabs (list)
"
"add two tabs
"   call base#map#add_tabs (list,2)

function! base#map#add_tabs (arr,...)
  let arr  = copy(a:arr)

  let ntabs = get(a:000,0,1)

  call map(arr,"substitute(v:val,'^','"  . repeat('\t',ntabs)  .  "','g')")

  return arr
endfunction

function! base#map#add_spaces (arr,...)
  let arr  = copy(a:arr)

  let nspaces = get(a:000,0,2)

  call map(arr,"substitute(v:val,'^','"  . repeat(' ',nspaces)  .  "','g')")

  return arr
endfunction
