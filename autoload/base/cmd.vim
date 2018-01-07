

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

	elseif opt == 'perl_exts'

	endif
	
endfunction
