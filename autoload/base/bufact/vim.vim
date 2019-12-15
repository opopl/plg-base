"""BufAct_lynx_dump_split
function! base#bufact#vim#insert_snip ()
  call base#buf#insert_snip()
endfunction

function! base#bufact#vim#stat ()
  call base#buf#stat()
endfunction

function! base#bufact#vim#tabs_nice ()
  call base#buf#tabs_nice()
endfunction

function! base#bufact#vim#source_script ()
  try
    silent so %
    call base#rdw('OK: source this buffer')
  catch 
    call base#rdwe(v:exception)
  finally
  endtry
endfunction
