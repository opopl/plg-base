"
"Usage
" call base#viewdat (dat)
"Call tree
" Calls
"   base#datafiles
"     base#sqlite#datfiles
"       base#init#sqlite
"       pymy#sqlite#query
"       base#dbfile
"   base#fileopen


function! base#dat#view (...)
  let dat = get(a:000,0,'')

  let dats = base#datlist()
  let dats = sort(dats)
  if ! strlen(dat)
    let desc = base#varget('desc_dat',{})
    let info = []
    for dat in dats
      call add(info,[ dat, get(desc,dat,'') ])
    endfor
    let lines = [ 'DAT files: ' ]
    call extend(lines, pymy#data#tabulate({
      \ 'data'    : info,
      \ 'headers' : [ 'dat', 'description' ],
      \ }))

    let cmds = []
    call add(cmds,'resize 99')
    call add(cmds,"vnoremap <buffer><silent> v :'<,'>call base#dat_vis#open()<CR>")
    call add(cmds,"vnoremap <buffer><silent> a :'<,'>call base#dat_vis#append()<CR>")
    call base#buf#open_split({ 
      \ 'lines'    : lines ,
      \ 'cmds_pre' : cmds,
      \ 'stl_add'  : [
        \ 'V[ v - view, a - append ]',
        \ ],
      \ })
    return
  endif

  let datfiles = base#datafiles(dat)

  let r = { 
    \ 'files'    : datfiles,
    \ 'load_buf' : 1 ,
    \ }
  call base#fileopen(r)
endf

function! base#dat#append (dat,lines)
  let ref = get(a:000,0,{})

  let dat   = a:dat
  let lines = a:lines

  let datfiles = base#datafiles(dat)
  for df in datfiles
    let r = {
          \   'lines'  : lines,
          \   'file'   : df,
          \   'mode'   : 'append',
          \   }
    call base#file#write_lines(r) 
  endfor
endf

