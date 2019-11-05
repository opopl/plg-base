
"	Purpose
"		For running scripts in scripts/ subdir
"
"	Usage
"		base#script#run({ 
"			\	'script' : script ,
"			\	'args'   : [ ... ],
"			\	'data'   : { ... },
"			\	})
"
function! base#script#run ( ... )
	let ref = get(a:000,0,{})

	let script = get(ref, 'script', '')
	let args   = get(ref, 'args', [])
	let data   = get(ref, 'data', {})

	let bat = base#qw#catpath('plg base scripts ' . script . '.bat')
	let cmd = bat
	
	let env = { 
		\	'script' : script,
		\	'data'   : data,
		\	'args'   : args,
		\	}

	function env.get(temp_file) dict
		let code = self.return_code
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
		endif
	endfunction
	
	call asc#run({ 
		\	'cmd' : cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})


	
endfunction

