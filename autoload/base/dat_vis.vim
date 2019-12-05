
function! base#dat_vis#open ()
  let lines = base#vim#visual_selection()

  if len(lines)
    q
    for line in lines
      let dat = base#dat_vis#dat_from_line(line) 
      call base#dat#view(dat)
    endfor
  endif

endfunction

function! base#dat_vis#dat_from_line (line)
  let line = a:line

  let dat = matchstr(line, '^\s*\(\d\+\)\s\+\zs\w\+\ze\s*$' )
  return dat
endfunction

function! base#dat_vis#append ()
  let vis_lines = base#vim#visual_selection()

  let msg_a = [
    \  " Line to append: ",
    \  ]
  let msg   = join(msg_a,"\n")
  let aline = base#input_we(msg,'')

  if !strlen(aline)
    call base#rdwe('nothing to append!')
    return
  endif

  for vline in vis_lines
    let dat = base#dat_vis#dat_from_line(vline) 

    let dat_value = base#varget(dat,[])
    if ! base#inlist(aline, dat_value)
      call base#dat#append(dat, [ aline ])
      call base#var#update(dat)
    endif
  endfor
endfunction
