
function! base#sync#run (...)
	let opt = get(a:000,0,'')

	if opt == 'plg'
		CD plg
	elseif base#inlist(opt,base#qw('projs_da projs_my projs'))
	endif
	
endfunction
