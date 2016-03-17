
"  base#tg#set (id)
"  base#tg#set ()
"

function! base#tg#set (...)
	if a:0
		let tg = a:1
	endif

	if tg     == 'ipte_ao'
	elseif tg == 'ipte_client'
	endif
	
endfunction

function! base#tg#update (...)
	if a:0
		let tg = a:1
	endif

	if tg     == 'ipte_ao'
	elseif tg == 'ipte_client'
	endif
	
endfunction
