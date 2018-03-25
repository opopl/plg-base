
function! base#bufact#idat#update_var ()
	call base#buf#start()

	if !exists("b:plg") | return | endif

	let vname = substitute(b:basename,'\.i\.dat$','','g')
	if !( b:plg == 'base')
		let vname = b:plg . '_' . vname
	endif
	
	call base#varhash#extend('datfiles',{ vname : b:file })
		
	call base#var#update(vname)
endf	
