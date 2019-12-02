
function! base#bufact_common#_file_add_to_db ()
  call base#buf#start()

  let fileid = base#input_we('fileid: ','',{})

  call base#db#file_add({ 
    \ 'file'   : b:file, 
    \ 'fileid' : fileid })
  
endfunction

function! base#bufact_common#help ()
  let help = []

  let data_h = []
  let maps = exists('b:maps') ? b:maps : {}

  let maps = get(maps,'nnoremap',{})
  for k in sort(keys(maps))
    let v = get(maps,k,'')
    call add(data_h,{ 'keys' : k, 'command' : v })
  endfor

  let d     = repeat('=',50)
  let lines = pymy#data#tabulate({
    \ 'data_h'  : data_h,
    \ 'headers' : [ 'keys' , 'command' ],
    \ })
  call extend(help,[ d, 'b:maps.nnoremap', d ])
  call extend(help,lines)
  call base#buf#open_split({ 'lines' : help })

endfunction

function! base#bufact_common#tabs_to_spaces ()
  setlocal et | retab

  redraw!
  echohl MoreMsg
  echo 'OK: TABS -> SPACES'
  echohl None
endfunction

function! base#bufact_common#dos2unix ()
  let file = bufname('%')
  let cmd = 'dos2unix ' . shellescape(file)

  let ok = base#sys({ 
    \ "cmds"         : [cmd],
    \ "split_output" : 0,
    \ })

endfunction

function! base#bufact_common#unix2dos ()
  let file = bufname('%')
  let cmd = 'unix2dos ' . shellescape(file)

  let ok = base#sys({ 
    \ "cmds"         : [cmd],
    \ "split_output" : 0,
    \ })
endfunction
