
function! base#bufact_common#_file_add_to_db ()
  call base#buf#start()

  let fileid = base#input_we('fileid: ','',{})

  call base#db#file_add({ 
    \ 'file'   : b:file, 
    \ 'fileid' : fileid })
  
endfunction

function! base#bufact_common#url_load_src ()

endfunction

"""bufact_help
function! base#bufact_common#help (...)
  let ref  = get(a:000,0,{})

  let help = []
	call insert(help, 'BUFFER DEFINED MAPS')

  let data_h = []
  let b_maps = exists('b:maps') ? b:maps : {}

  let map_types = keys(b_maps)
  let map_types = get(ref,'map_types',map_types)

  for map_type in map_types
    let maps = get(b_maps,map_type,{})

    for k in sort(keys(maps))
      let v = get(maps,k,'')
      call add(data_h,{ 'keys' : k, 'command' : v })
    endfor
  
    let d     = repeat('=',50)
    let lines = pymy#data#tabulate({
      \ 'data_h'  : data_h,
      \ 'headers' : [ 'keys' , 'command' ],
      \ })
    call extend(help,[ d, 'b:maps.' . map_type, d ])
    call extend(help,lines)

  endfor

  call add(help,d)
  call add(help,'SEE ALSO')
  call add(help,'	base#buf#maps')
  call add(help,'	base#bufact_common#help')
  call add(help,'	projs#maps')

  call base#buf#open_split({ 
    \ 'lines'    : help,
    \ 'cmds_pre' : [
      \ 'resize 99',
      \ 'MM tgadd_all',
      \ 'call matchadd("ModeMsg","<F.*>")',
      \ ],
    \ })

endfunction

function! base#bufact_common#nicify_copied ()
  %s/’/'/g

python3 << eof
import vim,re
b = vim.current.buffer
lines = [] 
for line in b:
  re.sub(r'’',r"'",line)
  lines.append(line)

b[:] = lines

eof
endfunction

function! base#bufact_common#tabs_to_spaces ()
  setlocal et | retab

  redraw!
  echohl MoreMsg
  echo 'OK: TABS -> SPACES'
  echohl None
endfunction

function! base#bufact_common#matches_delete ()
  call clearmatches()
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
