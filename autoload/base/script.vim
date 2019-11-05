
"For running scripts in scripts/ subdir
"
function! base#script#run ( ... )
	let ref = get(a:000,0,{})

	let script = get(ref, 'script', '')
	
endfunction
