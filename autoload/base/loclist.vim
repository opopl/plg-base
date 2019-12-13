
function! base#loclist#open ()
  lopen

  let mp = base#qf_list#maps()
  call base#buf#map_add(mp)

  call base#qf_list#statusline()
  
endfunction

function! base#loclist#close ()
  lclose
endfunction
