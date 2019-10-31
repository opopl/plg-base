
function! base#scp#data (...)

	let scp_data = base#varget('scp_data',{})
	if exists("b:scp_data")
		let scp_data = b:scp_data
	endif

	if a:0
		let id = get(a:000,0,'')
		let val = get(scp_data,id,'')
		return val
	else
		return scp_data
	endif

endfunction

function! base#scp#data_host(...)
	let slen = get(a:000,0,0)
	let host = base#scp#data("host")

	if slen
		if ( slen <	strlen(host) )
			let host = host[ 0:slen-1 ] . '...'
		endif
	endif
	return host
endfunction

function! base#scp#data_path_host()
	return base#scp#data("path_host")
endfunction

function! base#scp#data_basename()
	return base#scp#data("basename")
endfunction

function! base#scp#tfile()
	let tfile = base#qw#catpath('tagdir scp.tags')
	return tfile
endfunction

"	Called by
"		base#cmd_SCP#tags_make

function! base#scp#tags_make()
	let buf_nums  = base#scp#bufn()
	let buf_files = map(buf_nums,'bufname(v:val)')

	let tfile = base#scp#tfile()

	call base#ctags#run({ 
		\	'files' : buf_files, 
		\	'tfile' : tfile 
		\	})

	call base#tfile#process({ 'tfile' : tfile })

	call base#scp#tags_set()
endfunction

function! base#scp#tags_set()
	let tfile = base#scp#tfile()
	call base#tags#set(tfile)
endfunction

function! base#scp#bufn()
	let b = base#buffers#get()

	let buf_nums = get(b, 'bufnums', [])

	let bv = base#varget('buf_vars', {})

	let bufn = []

	for buf_num in buf_nums
		let bbv = get(bv, buf_num, {})

		let bv_list  = sort(keys(bbv))

		if base#inlist('scp_data', bv_list)
			call add(bufn, buf_num)
		endif
	endfor

	return bufn
endfunction

function! base#scp#stl()
	let stl = 'SCP\ #%n\ %1*\ '
	let stl .= '%{base#scp#data_basename()}\ %4*\ %l%0*'
	let stl .= '%5*\ %{base#scp#data_host(10)}\ %4*'
	return stl
endfunction

" used by:
" 	base#scp#fetch

function! base#scp#fetch_Fn (self,temp_file)
		let self      = a:self
		let temp_file = a:temp_file

		let code = self.return_code

		let basename = self.basename

		let msg = ['scp fetch file: ' . basename ]
		let prf = {'plugin' : 'base', 'func' : 'base#scp#fetch' }
		call base#log(msg,prf)

		redraw!
		if code == 0
			echohl MoreMsg
			echo 'SCP FETCH OK'
		else
			echohl WarningMsg
			echo 'SCP FETCH FAIL'
		endif
		echohl None

endfunction

function! base#scp#fetch (...)
	let ref      = get(a:000,0,{})

	let scp_data = get(ref,'scp_data',{})

	let scp_cmd_fetch = get(scp_data, 'scp_cmd_fetch' ,'' )
	let basename = get(scp_data, 'basename' ,'' )

	let env = { 'basename' : basename }
	function env.get(temp_file) dict
		call base#scp#fetch_Fn(self,a:temp_file)
	endfunction
	
	call asc#run({ 
		\	'cmd' : scp_cmd_fetch, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

endfunction

function! base#scp#send_Fn (self,temp_file)
		let self = a:self
		let temp_file = a:temp_file

		let code = self.return_code

		let basename = self.basename

		let msg = [ 'scp send file: ' . basename ]
		let prf = { 
			\	'plugin' : 'base', 
			\	'func' : 'base#scp#send' }
		call base#log(msg,prf)

		redraw!
		if code == 0
			echohl MoreMsg
			echo 'SCP SEND OK'
		else
			echohl WarningMsg
			echo 'SCP SEND FAIL'
		endif
		echohl None
endfunction


"call base#scp#send ({ 'scp_data' : scp_data })
"
"call base#scp#send ({ 
"		\	'scp_data' : scp_data ,
"		\	'Fc_file'  : Fc_file ,
"		\	})
"
"call base#scp#send ({ 
"		\	'scp_data' : scp_data ,
"		\	'file_cb'  : 'base#scp#cb_file',
"		\	})

function! base#scp#send (...)
	let ref = get(a:000,0,{})

	let scp_data = get(ref,'scp_data',{})

	let scp_cmd_send = get(scp_data, 'scp_cmd_send' ,'' )

	let local_file   = get(scp_data,'local_file','')
	let basename     = get(scp_data,'basename' ,'' )

	""" do something with the file before sending it
	let Fc_file = get(ref,'Fc_file','')

	let callbacks = []
	call add(callbacks,Fc_file)

	let file_cb_send = get(scp_data,'file_cb_send','')
	if strlen(file_cb_send)
		call add(callbacks, function(file_cb_send))
	endif

	for Cb in callbacks
		if type(Cb) == type(function('call'))
			call call(Cb, [ scp_data ])
		endif
	endfor

	let env = { 
				\ 'basename' : basename 
				\ }

	function env.get(temp_file) dict
		call base#scp#send_Fn(self, a:temp_file)
	endfunction
	
	call asc#run({ 
		\	'cmd' : scp_cmd_send, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

endfunction

"	Purpose
"		is called inside async callback, after async
"		call invoked via asc#run
"
"	Usage
"		call base#scp#open_Fn (self,temp_file)

function! base#scp#open_Fn (self, temp_file)
		let self      = a:self
		let temp_file = a:temp_file

		let code = self.return_code

		let scp_data = self.scp_data
		let exec     = get(self, 'exec', [])

		let au      = get(self, 'au', {})
		
		let Fc      = get(self, 'Fc', '')
		let Fc_args = get(self, 'Fc_args', [])

		""" callback for loading the file 
		"""		to be called before loading the file
    let Fc_file = get(self, 'Fc_file', '')

		let local_file    = scp_data.local_file
		let scp_cmd_fetch = scp_data.scp_cmd_fetch
		let path_host     = scp_data.path_host
		
		let msg = [ 
			\	"local_file: " . local_file, 
			\	"scp_cmd_fetch: " . scp_cmd_fetch, 
			\	"path_host: " . path_host,
	 		\	]

		let prf = { 'plugin' : 'base', 'func' : 'base#scp#open' }
		call base#log(msg,prf)
	
		if filereadable(temp_file)
			let out = readfile(temp_file)
			call base#varset('base_scp_last_output',out)
		endif

		if !filereadable(local_file)
			return
		endif

		let vc = []
		call add(vc, 'setlocal statusline=' . base#scp#stl() )
		call extend(vc, exec )

		let r = { 
				\	'files'   : [ local_file ],
				\	'exec'    : vc,
				\	'Fc'      : Fc,
				\	'Fc_args' : Fc_args,
				\	'au'      : au,
				\	}

		if type(Fc_file) == type(function('call'))
				let msg = ['Fc_file call on local_file']
				let prf = { 'plugin' : 'base', 'func' : 'base#scp#open_Fn' }
				call base#log(msg, prf)
			try
				call call(Fc_file, [ local_file ])
			catch
				let msg = ['Fc_file call errors']
				let prf = { 
					\	'plugin'      : 'base', 
					\	'func'        : 'base#scp#open_Fn',
					\	'v_exception' : v:exception,
					\	}
				call base#log(msg, prf)
			endtry
		endif

		try
    	call base#fileopen(r)
			let b:scp_data = scp_data
			call base#buf#vars_buf_set( bufnr('%'), 'scp_data', scp_data )
		catch 
			let msg = [ '(base#fileopen call) exception: ' . v:exception ]
			let prf = {
					\ 'plugin'   : 'base',
					\	'func'     : 'base#scp#open',
					\	'loglevel' : 'warn',
					\	'v_exception' : v:exception,
					\	}
			call base#log(msg,prf)
		endtry


endfunction

"	Usage:
"		call base#scp#open ({ 'path' : 'scp://...' })

function! base#scp#open (...)
	let ref  = get(a:000, 0, {})

	""" should be of type scp://
	let path = get(ref,'path','')

	""" additional vim commands to be run
	"""		when remote file is downloaded via scp
	"""   and then opened locally in a new buffer
	let exec = get(ref,'exec',[])

  """ autocommands to be applied to the local
  """   copy of the remote file
	let au = get(ref,'au',{})

  """ Funcref to be executed, after loading the file
	"""		into buffer, to be passed into base#fileopen
	let Fc      = get(ref,'Fc','')
	let Fc_args = get(ref,'Fc_args',[])

  """ Funcref to be executed on the file,
	"""		BEFORE loading the file into buffer,
	"""		thus before base#fileopen call
	let Fc_file = get(ref,'Fc_file','')

	""" to be saved to b:scp_data, what to do with the file
	"""		when sending it - before the actual sending
	let file_cb_send  = get(ref,'file_cb_send','')
  
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

	let local_file = join([ local_dir, basename ], "/" )
	let local_file = base#file#win2unix(local_file)

	let scp_cmd_fetch = join([ 'scp -P' , port, path_scp, local_file ], ' ')
	let scp_cmd_send = join([ 'scp -P' , port, local_file, path_scp ], ' ')

	let scp_data = { 
		\	'basename'      : basename,
		\	'host'          : host,
		\	'local_file'    : local_file,
		\	'path_host'     : path_host,
		\	'port'          : port,
		\	'scp_cmd_fetch' : scp_cmd_fetch,
		\	'scp_cmd_send'  : scp_cmd_send,
		\	'user'          : user,
		\	'file_cb_send'  : file_cb_send,
		\	}

	if filereadable(local_file)
		call delete(local_file)
	endif

	call base#varset('scp_data', scp_data)

	let env = {
		\	'exec'     : exec,
		\	'scp_data' : scp_data,
    \	'au'       : au,
    \	'Fc'       : Fc,
    \	'Fc_args'  : Fc_args,
    \	'Fc_file'  : Fc_file,
		\	}

	function env.get(temp_file) dict
		call base#scp#open_Fn( self, a:temp_file )
	endfunction
	
	call asc#run({ 
		\	'cmd' : scp_cmd_fetch, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

endfunction


