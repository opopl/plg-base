
fun! base#qw#catpath(...)

	let key = get(a:000, 0, '')
	let s   = get(a:000, 1, '')

	if ! strlen(key) | return '' | endif

	let pieces = base#qw(key)

	let first  = remove(pieces, 0)

	let s      = join(pieces, ' ') . ' ' . s

	let pa = base#qw(s)
	let p  = base#catpath(first, pa)

	return p

endf

fun! base#qw#catfile(s)
	let pa = base#qw(a:s)
	let p = base#file#catfile(pa)
	return p
endf

fun! base#qw#rf(key, s)
	let p = base#qw#catpath(a:key, a:s)

	let lines = []
	if filereadable(p)
		let lines = readfile(p)
	endif

	return lines

endf
