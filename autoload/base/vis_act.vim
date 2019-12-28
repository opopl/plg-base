
if 0
  Usage
    call base#vis_act#open_file()
    call base#vis_act#open_file({ 'mode' : 'num' })
    call base#vis_act#open_file({ 'mode' : 'num', 'dir' : dir })
endif

function! base#vis_act#open_file (...)
  let ref = base#varget('ref_vis_act_open_file',{})
  let ref = get(a:000,0,ref)

  let mode = get(ref,'mode','')
  let dir  = get(ref,'dir','')

  let lines = base#vim#visual_selection()

  let pats = {
      \ 'num' : '^\s*\d\+\s\+\zs.*\ze$'
      \  }

  let pat = ''
  let pat = get(pats,mode,pat)

  let files = []

  for line in lines
    let file = line
    if strlen(pat)
      let file = matchstr(line,pat)
    endif

    if strlen(file)
      if strlen(dir)
        let file = join([ dir, file ], '/')
      endif
      let file = base#file#win2unix(file)
      call add(files,file)
    endif
  endfor

  if !len(files) | return | endif
  q

  call base#fileopen({ 
     \ 'files'    : files ,
     \ 'load_buf' : 1     ,
     \ })

endfunction
