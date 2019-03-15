
function! base#var#update (varname)
	let varname = a:varname

  let datfiles = base#datafiles()
  let datlist  = base#datlist()

	let types = {
			\	'dict'      : 'Dictionary',
			\	'list'      : 'List',
			\	'listlines' : 'ListLines',
			\	}

"""var_update_fileids
	if varname == 'fileids'
		let files = base#exefile#files()

		let fileids = sort(keys(files))
		call base#varset('exefileids',fileids)

	elseif varname == 'datlist'
		let datlist = base#sqlite#datlist()
		call base#varset('datlist',datlist)

	elseif varname == 'datfiles'
		let datfiles = base#sqlite#datfiles()
		call base#varset('datfiles',datfiles)

"""var_update_plugins_all
	elseif varname == 'plugins_all'
		let var = base#find({ 
			\	"dirids"    : ['plg'],
			\	"relpath"   : 1,
			\	"subdirs"   : 0,
			\	"dirs_only" : 1,
			\	"pat_exclude" : '^.git',
			\	})
    call base#varset(varname,var)

  elseif base#inlist(varname,datlist)
    let datfile = get(datfiles,varname,'')
    let dfu     = base#file#win2unix(datfile)

    let typedir = fnamemodify(dfu,':p:h:t')
		let type    = get(types,typedir,'')

    let data = base#readdatfile({ 
        \   "file" : datfile ,
        \   "type" : type ,
        \   })
		echo varname

    call base#varset(varname,data)
	else
		return
	endif

	let prf={ 'func' : 'base#var#update','plugin' : 'base' }
	call base#log([
		\	'updated: ' . varname,
		\	],prf)
	return

endfunction

function! base#var#dump_split (varname)
		let val       = base#varget(a:varname)
    let dump      = base#dump(val)
		
		let dumplines = split(dump,"\n")
		let sz   = len(dumplines)
		let last = sz-1

		let a = []
		call add(a,'if exists("w") | unlet w | endif')
		call add(a,' ')
		call add(a,'let w='.base#list#get(dumplines,0))

		if last>0
			let b = base#list#get(dumplines,'1:'.last)
			call extend(a,map(b,"'\t\\ ' . v:val"))
		endif

		call base#buf#open_split({ 'lines' : a })
	
endfunction
