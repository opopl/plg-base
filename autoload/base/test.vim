
function! base#test#type_ok (varname,var,type,...)
	let varname = a:varname
	let var     = a:var

	let type    = a:type

	let ok  = ( base#type(var) == type ) ? 1 : 0
	let oks = ok ? 'OK  ' : 'FAIL'

	let msgs = []

	call add(msgs,oks . ' variable: ' . varname . ' ' . ' should be of type: ' . type)
	call base#log(msgs,{ 
		\	'prf'  : 'base#test#type_ok', 
		\	'echo' : 1 })

	return ok
	
endfunction
