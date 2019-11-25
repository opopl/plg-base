

function! base#cmd#FIND (...)
	let opt = get(a:000,0,'')

	if opt == 'dirid_exts'
		let olddir = getcwd()

		let dirid  = input('DIRID:','','custom,base#complete#CD')
		let exts_s = input('Extensions (separated by space):','')
		let exts_a = split(exts_s," ")
		let pat    = input('Pattern:','')

		let ff = base#find({ 
			\	"dirids"  : [dirid],
			\	"exts"    : exts_a,
			\	"relpath" : 1,
			\	"pat"     : pat,
			\	})
		call base#buf#open_split({ 
			\	'lines' : ff })
		call base#CD(dirid)

	elseif opt == 'cwd_perl_exts'
		let exts_a = base#qw('pm pl t')
		let dir = getcwd()

		let dirs = []
		call add(dirs,dir)

		let pat    = input('Pattern:','')

		let ff = base#find({ 
			\	"dirs"  : [dir],
			\	"exts"    : exts_a,
			\	"relpath" : 1,
			\	"pat"     : pat,
			\	})
		call base#buf#open_split({ 
			\	'lines' : ff })

	endif
	
endfunction

"cmds:
"  base#cmd_SSH#run

function! base#cmd#SSH (...)
	let cmd = get(a:000,0,'')

	let sub = 'base#cmd_SSH#' . cmd 
	exe 'call ' . sub . '()'
endfunction

"cmds:
"  base#cmd_SCP#list_bufs

function! base#cmd#SCP (...)
	let cmd = get(a:000,0,'')

	let sub = 'base#cmd_SCP#' . cmd
	exe 'call ' . sub . '()'
endfunction

function! base#cmd#WHERE (...)
	let l:opt = get(a:000,0,'')

	let hist = base#varref('WHERE_hist',[])
	call add(hist,l:opt)
	let hist = base#uniq(hist)

	let files = base#where(opt)
	call base#buf#open_split({ 'lines' : files })

	let data = base#varref('WHERE_data',{})
	call extend(data,{ opt : files })

endfunction
