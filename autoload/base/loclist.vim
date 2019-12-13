
function! base#loclist#open ()
  let llist = getloclist(0)

  if !len(llist)
    return 
  endif

  botright lopen

  let mp = base#qf_list#maps()
  call base#buf#map_add(mp)

  call base#qf_list#statusline()
  
endfunction

function! base#loclist#close ()
  lclose
endfunction
