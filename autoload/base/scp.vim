
function! base#scp#open (...)
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

	let path_host = get(m, 4, '')
	let path_scp  = user . '@' . host . ':' . path_host

	let basename = fnamemodify(path_host,':t')

	let tmp_scp = base#qw#catpath('hm tmp_scp')
	let local_dir = tmp_scp . '/' . fnamemodify(path_host,':h')
	call base#mkdir(local_dir)

	let local_file = join([local_dir,basename],"/")
	let local_file = base#file#win2unix(local_file)

	if filereadable(local_file)
		call delete(local_file)
	endif

	let scp_cmd = join([ 'scp -P' , port, path_scp, local_file ], ' ')

	let scp_data = { 
		\	'basename'   : basename,
		\	'local_file' : local_file,
		\	'scp_cmd'    : scp_cmd,
		\	'path_host'  : path_host,
		\	}

	let env = {}
	call extend(env,scp_data)

	call base#varset('scp_data',scp_data)

	function env.get(temp_file) dict

		let code = self.return_code

		let local_file = self.local_file
		let scp_cmd    = self.scp_cmd
		let path_host  = self.path_host
		
		let msg = [ 
			\	"local_file: " . local_file, 
			\	"scp_cmd: " . scp_cmd, 
			\	"path_host: " . path_host,
	 		\	]

		let prf = {'plugin' : 'base', 'func' : 'base#scp#open' }
		call base#log(msg,prf)
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
			if filereadable(local_file)
				let vc = 'setlocal statusline=REMOTE["%s"]'
				let vc = printf(vc, path_host)

				let r = { 
					\	'files' : [ local_file ],
					\	'exec'  : [ ],
					\	}
				call base#fileopen(r)
			endif
			"call base#buf#open_split({ 'lines' : out })
		endif
	endfunction
	
	call asc#run({ 
		\	'cmd' : scp_cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

endfunction

function! base#scp#data (...)

	let scp_data = base#varget('scp_data',{})
	if a:0
		let id = get(a:000,0,'')
		let val = get(scp_data,id,'')
		return val
	else
		return scp_data
	endif

endfunction
	
