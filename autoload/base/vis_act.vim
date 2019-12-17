
function! base#vis_act#open ()
  let lines = base#vim#visual_selection()

  if len(lines)
    q
    for line in lines
			call base#fileopen({ 'files': [line] })
    endfor
  endif

endfunction
