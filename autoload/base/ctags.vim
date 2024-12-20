

"Usage
"		call base#ctags#run({ 
"			\	'files' : files, 
"			\	'tfile' : tfile 
"			\	})
"
"Call tree
"		Used by
"			base#cmd_SCP#buf_add_tags

function! base#ctags#run (...)
	let ref = get(a:000,0,{})

	let tfile = get(ref,'tfile','')
	let Cb    = get(ref,'Cb','')

	let tfile_se = shellescape(tfile) 
	if has('win32')
		let tfile_win = base#file#unix2win(tfile)
		let tfile_se = shellescape(tfile_win) 
	endif

	let files    = get(ref,'files',[])

	if has('win32')
		let files_se = map(copy(files),'base#file#win2unix(shellescape(v:val))')
	else
		let files_se = map(copy(files),'shellescape(v:val)')
	endif

	let cmd_a = [ 'ctags -R -o', tfile_se ]
	call extend(cmd_a, files_se )

	let cmd = join(cmd_a, " ")

	let env = { 
		\	'cmd_ctags' : cmd ,
		\	'tfile'     : tfile,
		\	'Cb'        : Cb,
		\	}

	function env.get(temp_file) dict
		call base#ctags#run_Fn(self,a:temp_file)

		let Cb    = get(self,'Cb','')
		let tfile = get(self,'tfile','')

		if type(Cb) == type( function('call') ) || strlen(Cb)
			try
				call call(Cb,[ tfile ])
			catch 
				let msg = [
					\	'tfile callback fail',
					\	]
				let prf = {
					\	'loglevel'    : 'warn',
					\	'v_exception' : v:exception,
					\	'plugin'      : 'base',
					\	'func'        : 'base#ctags#run_Fn'
					\	}
				call base#log(msg,prf)
			endtry
		endif

	endfunction
	
	call asc#run({ 
		\	'cmd' : cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})
	
endfunction

function! base#ctags#run_Fn (self,temp_file)
		let self      = a:self
		let temp_file = a:temp_file
		
		let code = self.return_code
		let tfile = get(self,'tfile','')

		let info = []
		call add(info,'CTAGS RETURN CODE:')
		call add(info,' ' . code)
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
			if len(out)
				call base#buf#open_split({ 'lines' : out })
			endif
		endif

		"call base#buf#open_split({ 'lines' : info })
endfunction
