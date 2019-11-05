
"	Purpose
"		For running scripts in scripts/ subdir
"
"	Usage
"		base#script#run({ 'script' : script })
"
function! base#script#run ( ... )
	let ref = get(a:000,0,{})

	let script = get(ref, 'script', '')
	let Fc = get(ref, 'Fc', '')
	
endfunction
