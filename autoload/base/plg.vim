
"function! base#plg#loadfun(...)
"endf


function! base#plg#loaded (...)
	let plg=a:1
	if !base#varexists('plugins')
		return 0
	endif
	let plugins = base#varget('plugins',[])

	if !base#inlist(plg,plugins)
		return 0
	endif

	return 1 	
endfunction

function! base#plg#loadvars (...)

	if a:0
		let plg = get(a:000,0,'')
		let ref = get(a:000,1,{})
	endif

	let opts_readarr  = get(ref,'opts_readarr',{})
	let opts_readdict = get(ref,'opts_readdict',{})

	let types = base#qw('list dict')
	
	let rpath = plg.' '.'data'

  let datfiles = base#varget('datfiles',{})

	for type in types
		let typedir = base#qw#catpath('plg',rpath.' '.type)
	
		let ext  = "i.dat"
		let exts = [ ext ]

		let fnames = base#find({ 
			\	"dirs"    : [typedir],
			\	"exts"    : exts,
			\	"relpath" : 1,
			\	"rmext"   : 1,
			\	})
	
		for fname in fnames
			let vname = plg.'_'.fname

      "" full path to the datfile
			let df    = base#file#catfile([ typedir, fname .'.'.ext ])

      call extend(datfiles,{ vname : df })

			if type == 'list'
				let vv = base#readarr(df,opts_readarr)
			else
				let rf = { 'file' : df }
				call extend(rf,opts_readdict)
				let vv = base#readdict(rf)

			endif
	
			call base#varset(vname,vv)
			if exists("vv") | unlet vv | endif 
		endfor
	endfor

	let vars = base#varget(plg.'_vars',{})
	if type(vars) == type({})
		for [k,v] in items(vars)
				call base#varset(plg.'_'.k,v)
		endfor
	endif

  call base#varset('datfiles',datfiles)

  let datlist=base#varhash#keys('datfiles')
  call base#varset('datlist',datlist)

endfunction

function! base#plg#opendat (...)
		let plg	= get(a:000,0,'')

		let type = input('Type:','list','custom,base#complete#dattypes')

		let dir = base#qw#catpath('plg',plg . ' data ' . type)

		let files = base#find({ 
				\	"dirs"    : [ dir ],
				\	"exts"    : ['i.dat'],
				\	"relpath" : 1,
				\	"cwd"     : 0 })

		let df=base#getfromchoosedialog({ 
				\ 'list'        : files,
				\ 'startopt'    : get(files,0,''),
				\ 'header'      : "Available dat files are: ",
				\ 'numcols'     : 1,
				\ 'bottom'      : "Choose dat files by number: ",
				\ })
		let df = base#file#catfile([ dir, df ])

		call base#fileopen({ 
      \ "files"  : [ df ],
      \ 'action' : 'split'
      \ })

		call base#tg#add('plg_'.plg)
		call base#stl#set('plg')
	
endfunction
