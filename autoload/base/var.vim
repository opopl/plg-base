
function! base#var#update (varname)
	let varname = a:varname

	if varname == 'fileids'
		let files = base#f#files()

		let fileids = sort(keys(files))
		call base#varset('fileids',fileids)
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
