

function! base#plg#loadvars (...)
	if a:0
		let plg = a:1
	endif

	let types = base#qw('list dict')
	
	let rpath = plg.' '.'data'

	for type in types
		let typedir = base#qw#catpath('plg',rpath.' '.type)
	
		let ext = "i.dat"
		let exts = [ ext ]

		let fnames = base#find({ 
			\	"dirs" : [typedir], 
			\	"exts" : exts,
			\	"relpath" : 1,
			\	"rmext" : 1,
			\	})
	
		for fname in fnames
			let vname = plg.'_'.fname
			let df = base#file#catfile([ typedir, fname .'.'.ext ])

			if type == 'list'
				let vv = base#readarr(df)
			else
				let vv = base#readdict(df)
			endif
	
			call base#var(vname,vv)
			if exists("vv") | unlet vv | endif 
		endfor
	endfor

endfunction
