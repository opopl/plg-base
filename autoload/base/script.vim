
"	Purpose
"		For running scripts in scripts/ subdir
"
"	Usage
"		base#script#run({ 
"			\	'script' : script ,
"			\	'dir'    : dir ,
"			\	'args'   : [ ... ],
"			\	'data'   : { ... },
"			\	})
"

function! base#script#run ( ... )
	let ref = get(a:000, 0, {})

	let script = get(ref, 'script', '')

	let dir = base#qw#catpath('plg base scripts')
	let dir = get(ref, 'dir', dir)

	let args   = get(ref, 'args', [])
	let data   = get(ref, 'data', {})

	let ext = has('win32') ? 'bat' : 'sh'
	let bat_file  = join([ dir, script . '.' . ext ],'/')

	let data_json = base#json#encode(data)

	let data_file  = join([ dir, script . '_data.json' ],'/')

	let r = {
	      \   'text'   : data_json,
	      \   'file'   : data_file,
	      \   }
	call base#file#write_lines(r)	

	let a = [ bat_file ] 
	call extend(a,args)
	let cmd = join(a, ' ')
	
	let env = { 
		\	'script' : script,
		\	'data'   : data,
		\	'args'   : args,
		\	}

	function env.get(temp_file) dict
		let code = self.return_code
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
			call base#buf#open_split({ 'lines' : out })
		endif
	endfunction
	
	call asc#run({ 
		\	'cmd' : cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

endfunction

