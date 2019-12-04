
function! base#dat_vis#open ()
  let lines = base#vim#visual_selection()

  for line in lines
    let dat = matchstr(line, '^\s*\(\d\+\)\s\+\zs\w\+\ze\s*$' )
    q
    call base#dat#view(dat)
  endfor

endfunction
