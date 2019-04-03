
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

function! base#var#to_xml (...)
	let var_name  = get(a:000,0,'')

	let vars = base#vars()

	let var_list = []
	if !strlen(var_name)
		let var_list = base#varlist()
	else
		call add(var_list,var_name)
	endif

	if has('python3')
python3 << eof

import vim
import lxml.etree as et

var_list = vim.eval('var_list')
vars     = vim.eval('vars')

vars_p = {}
#print(var_list)

for var_name in var_list:
	vars_p[var_name] = vars.get(var_name)

print(vars_p)

def data2xml(d, name='data'):
    r = et.Element(name)
    return et.tostring(buildxml(r, d), pretty_print=True)

def buildxml(r, d):
    if isinstance(d, dict):
        for k, v in d.items():
            s = et.SubElement(r, k)
            buildxml(s, v)
    elif isinstance(d, tuple) or isinstance(d, list):
        for v in d:
            s = et.SubElement(r, 'i')
            buildxml(s, v)
    elif isinstance(d, str):
        r.text = d
    else:
        r.text = str(d)
    return r

vars_xml = data2xml(vars_p,name='vars')
	
eof
		return py3eval('vars_xml')

	endif
endfunction

function! base#var#dump_xml (...)
	let var_name  = get(a:000,0,'')

	let xml = base#var#to_xml(var_name)

	if strlen(xml)
		call base#buf#open_split({ 'text' : xml })
	endif

endfunction
