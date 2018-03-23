
function! base#bufact#idat#update_var ()
	call base#buf#start()

	let vname = substitute(b:basename,'\.i\.dat$','','g')
	call base#var#update(vname)
endf	
