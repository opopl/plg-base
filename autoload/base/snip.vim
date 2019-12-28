
if 0
  call tree
    called by
      base#rtp#add_plugin
endif

function! base#snip#add_dir (...) 
  let sdir = get(a:000,0,'')

  if !isdirectory(sdir)
    return
  endif
  
  if !exists("g:snippets_dir")
    let g:snippets_dir = sdir
  else
    let g:snippets_dir .= "," . sdir
  endif
endfunction
