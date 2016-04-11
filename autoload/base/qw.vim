
fun! base#qw#catpath(key,s)
	let pa = base#qw(a:s)
	let p = base#catpath(a:key,pa)
	return p

endf

fun! base#qw#catfile(s)
	let pa = base#qw(a:s)
	let p = base#file#catfile(pa)
	return p
endf

fun! base#qw#rf(key,s)
	let p = base#qw#catpath(a:key,a:s)

	let lines=[]
	if filereadable(p)
		let lines=readfile(p)
	endif

	return lines

endf
