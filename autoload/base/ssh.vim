
function! base#ssh#scp_file_open (...)
	let ref  = get(a:000, 0, {})

	""" should be of type scp://
	let path = get(ref,'path','')

			"\	'scp' : '^\zsscp://\(\w\+\)@\ze\([\S\+^:]\):\(\d\+\)/\(.*\)',

	let pats = {
			\	'scp' : '^\zsscp://\(\w\+\)@\(\S\+\):\(\d\+\)/\(.*\)',
			\	}
	let m = matchlist(path, pats.scp)

	let user = get(m,1,'')
	let host = get(m,2,'')
	let port = get(m,3,'')

	let path_host = get(m,4,'')
	let path_scp = user . '@' . host . ':' . path_host

	let scp_cmd = join(['scp -P', port, path_scp ], ' ')

endfunction

function! base#ssh#run (...)
	let ref = get(a:000,0,{})

	let start_dir  = get(ref, 'start_dir', '')
	let cmds_user  = get(ref, 'cmds_user', [])
	let cmd_core   = get(ref, 'cmd_core', [])

	let cmds_remote = []
	call add(cmds_remote, 'cd ' . start_dir )
	call extend(cmds_remote, cmds_user )

	let cmd_remote = join(cmds_remote, ' ; ')

	let cmd_full = join([ cmd_core, cmd_remote ], " ")
	
	let env = { 
		\	'cmd_remote' : cmd_remote
 		\		}
	function env.get(temp_file) dict
		let code = self.return_code

		let cmd_remote = self.cmd_remote
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
			call base#buf#open_split({ 
				\	'lines'    : out ,
				\	'cmds_pre' : [ 
						\	'setlocal statusline=' . escape(cmd_remote,' ')
						\	] 
				\	})
		endif
	endfunction
	
	call asc#run({ 
		\	'cmd' : cmd_full, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

endfunction
