
if 0
  Usage
    call base#vis_act#open_file()
    call base#vis_act#open_file('num')
endif

function! base#vis_act#open_file (...)
  let mode = get(a:000,0,'')

  let lines = base#vim#visual_selection()

  let pats = {
      \ 'num' : '^\s*\d\+\s\+\zs.*\ze$'
      \  }

  let pat = ''
  let pat = get(pats,mode,pat)

  if !len(lines) | return | endif

  q
  for line in lines
    let file = line
    if pat
      let file = matchstr(line,pat)
    endif

  endfor

  call base#fileopen({ 
     \ 'files'    : files ,
     \ 'load_buf' : 1     ,
     \ })

endfunction
