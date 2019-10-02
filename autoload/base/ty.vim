
function! base#ty#make (...)
	let ref = get(a:000, 0, {})

	let dirs  = get(ref,'dirs',[])
	let tfile = get(ref,'tfile','')
	let tgid  = get(ref,'tgid','')
	let dbfile  = get(ref,'dbfile','')

	let ok = 1

	let args = []
	let opts = [ 
				\	'--tfile', tfile,
				\	]
	let bat_file = base#qw#catpath('tmp_bat' , tgid . '.bat')

	for dir in dirs
		call extend(opts,[ '--dir', dir ])
	endfor
	call extend(opts,[ '--db', dbfile ])
	call extend(opts,[ '--action', 'generate_from_fs' ])

	let cmd = base#bat#cmd_for_exe({ 
		\	'opts'     : opts,
		\	'args'     : args,
		\	'exe'      : 'ty',
		\	'bat_file' : bat_file,
		\	})
	
	let env = { 
		\	'tgid' : tgid,
		\	}

	function env.get(temp_file) dict
		let code = self.return_code
		let ok   = ( code == 0 ) ? 1 : 0 

		let tgid = get(self, 'tgid', '' )
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
			call base#buf#open_split({ 'lines' : out })
		endif

		let okref = { 
			\	"tgid" : tgid,
			\	"ok"   : ok,
			\	"add"  : 1, 
			\	}

		let ok = base#tg#ok(okref)
	endfunction
	
	call asc#run({ 
		\	'cmd' : cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

	return ok
	
endfunction
