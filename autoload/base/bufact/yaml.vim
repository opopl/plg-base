"""BufAct_lynx_dump_split
function! base#bufact#yaml#set_et_retab ()
  call base#buf#start()

  setlocal et 
  retab

endfunction

function! base#bufact#yaml#check_syntax ()
  let file = b:file
  let d = base#yaml#parse_fs({ 'file' : file })

endfunction
