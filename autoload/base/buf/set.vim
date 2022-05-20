
function! base#buf#set#paste ()
  setlocal paste
  call base#rdw('setlocal paste')

endfunction

function! base#buf#set#ignorecase ()
  setlocal ignorecase
  call base#rdw('CASE IGNORE')
endfunction

function! base#buf#set#no_ignorecase ()
  setlocal noignorecase
  call base#rdw('CASE NO-IGNORE')
endfunction

function! base#buf#set#no_keymap ()
  setlocal keymap=
  call base#rdw('NO KEYMAP')
endfunction


function! base#buf#set#nopaste ()
  setlocal nopaste
  call base#rdw('setlocal nopaste')

endfunction
