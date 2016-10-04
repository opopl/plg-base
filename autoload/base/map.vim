
function! base#map#fnamemodify (arr,mods)
	let arr  = copy(a:arr)
	let mods = a:mods

	call map(arr,'fnamemodify(v:val,mods)')

	return arr
endfunction
