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

  if ! strlen(dat)
    call base#dat#render_list()
    return
  endif

  let datfiles = base#datafiles(dat)

  let r = { 
    \ 'files'    : datfiles,
    \ 'load_buf' : 1 ,
    \ }
  let res = base#fileopen(r)

  let buf_nums = get(res,'buf_nums',[])

  if len(buf_nums)
    let dat_bufs = base#varref('dat_bufs',{})
    call extend(dat_bufs,{ dat : buf_nums })
  endif
endf

if 0
  call tree
    calls
      base#datlist
        base#datafiles
          base#sqlite#datfiles
            pymy#sqlite#query
  sql
    SELECT DISTINCT datfile FROM datfiles WHERE keyfull = ?
    SELECT keyfull, datfile FROM datfiles
endif

function! base#dat#render_list ()
  let dats = base#datlist()
  let dats = sort(dats)

  let cmds_pre = []

  let desc = base#varget('desc_dat',{})
  let info = []
  for dat in dats
    let buf_nums = base#dat#buf_nums(dat)
    let buf_str  = join(buf_nums, ' ')
    call add(info,[ dat, buf_str, get(desc, dat, '') ])

    if len(buf_str)
      call add(cmds_pre, "call matchadd('MoreMsg','\\s\\+".dat."\\s\\+')")
    endif
  endfor

  let delim = repeat( 'x', 50 )

  let lines = []
  call extend(lines,['BaseDatView'])
  call extend(lines,[
    \ delim,
    \ ' Vim Functions: ',
    \ '   base#dat#render_list base#dat#view',
    \ delim,
    \ ])


  call extend(lines,['List of DAT files: '])
  call extend(lines, pymy#data#tabulate({
    \ 'data'    : info,
    \ 'headers' : base#qw('dat buf description'),
    \ }))

  call add(cmds_pre,'resize 99')
  call add(cmds_pre,'MM tgadd_all')
  call add(cmds_pre,"vnoremap <buffer><silent> v :'<,'>call base#dat_vis#open()<CR>")
  call add(cmds_pre,"vnoremap <buffer><silent> a :'<,'>call base#dat_vis#append()<CR>")

  call base#buf#open_split({ 
    \ 'lines'    : lines ,
    \ 'cmds_pre' : cmds_pre,
    \ 'stl_add'  : [
      \ 'V[ %1* v - view, %2* a - append %0* ]',
      \ ],
    \ })
  return
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

function! base#dat#buf_nums (dat)
  let dat   = a:dat

  let dat_bufs = base#varref('dat_bufs',{})
  let buf_nums = get(dat_bufs,dat,[])
  return buf_nums
endf

