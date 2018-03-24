
function! base#bufact#idat#update_var ()
	call base#buf#start()

	let vname = substitute(b:basename,'\.i\.dat$','','g')

	if exists("b:plg")
		 if !( b:plg == 'base')
				let vname = b:plg . '_' . vname
		 endif
		
	endif
	call base#var#update(vname)
endf	
