

function! base#where#first (file,...)
	let files = base#where(a:file)
	let first = get(files,0,'')
	return first
endf
