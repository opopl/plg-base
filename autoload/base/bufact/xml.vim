
function! base#bufact#xml#xpath ()
	call base#buf#start()

  call base#bufact#html#xpath ()
endf

function! base#bufact#xml#quickfix_xpath ()
	call base#buf#start()

  call base#bufact#html#quickfix_xpath ()

endf
