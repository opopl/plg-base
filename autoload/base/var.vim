
function! base#var#update (varname)
	let varname = a:varname

  let datlist  = base#varget('datlist',[])
  let datfiles = base#varget('datfiles',{})

	if varname == 'fileids'
		let files = base#exefile#files()

		let fileids = sort(keys(files))
		call base#varset('exefileids',fileids)

  elseif base#inlist(varname,datlist)
    let datfile = get(datfiles,varname,'')
    let dfu = base#file#win2unix(datfile)

    let type = fnamemodify(dfu,':p:h:t')

    let data = base#readdatfile({ 
        \   "file" : datfile ,
        \   "type" : type ,
        \   })
    call base#varset(varname,data)
	endif

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
