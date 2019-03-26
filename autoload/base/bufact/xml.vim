
"""xpath
function! base#bufact#xml#xpath ()
	call base#buf#start()

  call base#bufact#html#xpath ()
endf

"""remove_xpath
function! base#bufact#xml#remove_xpath ()
	call base#buf#start()

  call base#bufact#html#remove_xpath ()
endf

"""quickfix_xpath
function! base#bufact#xml#quickfix_xpath ()
	call base#buf#start()

  call base#bufact#html#quickfix_xpath ()

endf

"""pretty_perl_libxml

function! base#bufact#xml#pretty_perl_libxml ()
	call base#buf#start()

  call base#bufact#html#pretty_perl_libxml ()

endf
