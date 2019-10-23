

function! base#ssh#run (...)
	let ref = get(a:000,0,{})

	let start_dir  = get(ref, 'start_dir', '')
	let cmds_user  = get(ref, 'cmds_user', [])
	let cmd_core   = get(ref, 'cmd_core', '')

	let s:dict = {}
	function s:dict.init(code, out) dict
	endfunction 

	let Fc   = get(ref, 'Fc', s:dict.init )

	let cmds_remote = []
	call add(cmds_remote, 'cd ' . start_dir )
	call extend(cmds_remote, cmds_user )

	let cmd_remote = join(cmds_remote, ' ; ')

	let cmd_full = join([ cmd_core, cmd_remote ], " ")
	
	let env = { 
		\	'cmd_remote' : cmd_remote,
		\	'Fc'         : Fc,
 		\		}

	function env.get(temp_file) dict
		let code = self.return_code

		let Fc = self.Fc

		let cmd_remote = self.cmd_remote
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)

			try
				call call(Fc,[ code, out ])
			catch
				echo v:exception
			endtry

			call base#qf_list#set({ 'arr' : out })
			call base#varset('ssh_run_out',out)

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

function! base#ssh#file_size (...)
	let ref = get(a:000, 0, {})

	let path = get(ref,'path','')

	let cmd_core = burdev#opt#get("cmd_ssh_remote")

	let start_dir = fnamemodify(':h',path)
	let start_dir = base#file#win2unix(start_dir)

	let cmd = 'wc -c ' . path
	let cmds_user = [ cmd ] 

	let s:dict = {}
	function s:dict.init(code, out) dict
	endfunction 

	let r = {
		\	'start_dir' : start_dir,
		\	'cmds_user' : cmds_user,
		\	'cmd_core' : '',
		\	'Fc'       : s:dict.init,
		\	}
	call base#ssh#run(r)

endfunction
