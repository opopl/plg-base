

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
			call base#qf_list#set({ 'arr' : out })

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
