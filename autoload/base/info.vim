
function! base#info#dbext ()
	let varnames = base#varget('varnames_dbext',[])

	let lines = []

	for varname in varnames
		let val = base#value#var(varname)
		let a = varname .' => '.val
		call add(lines,a)
	endfor

	call base#buf#open_split({ 'lines' : lines })
	
endfunction

function! base#info#topics ()
	let topics = base#varget('info_topics',[])
	let topics = sort(topics)
	return topics
endfunction
