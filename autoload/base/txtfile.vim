
"call base#txtfile#insert ({
"}
")

function! base#txtfile#insert (...)
	let ref    = get(a:000,0,{})
	let file   = get(ref,'file','')
	let string = get(ref,'string','')
	let where  = get(ref,'where','')
	let cond   = get(ref,'cond','')

	let flines=[]

	if filereadable(file)
		let flines=readfile(file)
	endif

	if cond == 'only_if_absent'
		if ! base#list#contains_matches(flines,'^'.string.'$')
			return
		endif
	endif

	if where == 'at_end'
		call add(flines,string)
	elseif where == 'at_start'
		call base#list#unshift(flines,string)
	endif

	call writefile(flines,file)
	
endfunction
