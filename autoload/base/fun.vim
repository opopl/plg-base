
function! base#fun#new ()
	let s:obj = {}
	function! s:obj.init () dict
		return self
	endfunction
	
	let Fc = s:obj.init
	return Fc
endfunction
