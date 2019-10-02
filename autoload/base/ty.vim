
function! base#ty#make (...)
	let ref = get(a:000, 0, {})

	let dirs   = get(ref, 'dirs'  ,[])
	let tfile  = get(ref, 'tfile' ,'')
	let tgid   = get(ref, 'tgid'  ,'')
	let dbfile = get(ref, 'dbfile' ,'')

	let redo   = get(ref, 'redo', 0 )

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
	call extend(opts,[ '--redo', redo ])

	let ty_pl = base#qw#catpath('htmltool', 'bin ty.pl')
	let exe_perl = get(ref, 'exe_perl', 'perl')

	let exe = exe_perl . ' ' . shellescape(ty_pl) 

	let cmd = base#bat#cmd_for_exe({ 
		\	'opts'     : opts,
		\	'args'     : args,
		\	'exe'      : exe,
		\	'bat_file' : bat_file,
		\	})

	let l:start = localtime()
	
	let env = { 
		\	'tgid' : tgid,
		\	'start' : l:start,
		\	}

	function env.get(temp_file) dict
		let code = self.return_code
		let ok   = ( code == 0 ) ? 1 : 0 

		let tgid  = get(self, 'tgid', '' )

		let l:start = get(self, 'start', '' )
		let l:end = localtime()
		let l:el  = l:end - l:start
		let l:els = ' ' . l:el . ' secs'
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
			call base#buf#open_split({ 'lines' : out })
		endif

		let okref = { 
			\	"tgid" : tgid,
			\	"ok"   : ok,
			\	"add"  : 0, 
			\	}

		let ok = base#tg#ok(okref)
	endfunction
	
	call asc#run({ 
		\	'cmd' : cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

	return ok
	
endfunction
