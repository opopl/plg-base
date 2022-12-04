
"""BufAct_lynx_dump_split
function! base#bufact#json#set_et_retab ()
  call base#buf#start()

  setlocal et 
  retab

endfunction

function! base#bufact#json#show ()
  let file = b:file
  let d = base#json#decode({ 'file' : file })
  let dmp = base#dump(d)
  call base#buf#open_split({ 'text' : dmp })

endfunction


function! base#bufact#yaml#check_syntax ()
  let file = b:file

  try
    let d = base#yaml#parse_fs({ 'file' : file })
    call base#rdw(printf('YAML Syntax OK: %s',b:basename))
  catch
    call base#rdwe(printf('YAML Syntax FAIL: %s',b:basename))
  endtry

endfunction
