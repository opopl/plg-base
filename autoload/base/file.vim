
function! base#file#catfile( ... )
	
	if ! a:0 | return '' | endif

	if type(a:1) == type([])
			let pieces = a:1
			let sep = has('win32') ? '\' : '/'

			let pieces = map(pieces,'base#file#catfile(v:val)')

			let path = join(pieces,sep)
			let path = base#file#std(path)

			return path 

	elseif type(a:1) == type({})
			let dirs=a:1

			let d=[]
			for id in keys(dirs)
					unlet d
					let d=dirs[id]
					if type(d) == type([])
						let dirs[id]=base#file#catfile(d)
					endif
			endfor

			return dirs

	elseif type(a:1) == type('')
			let path = a:1

			return path
	endif

endf

function! base#file#sep ()
	if has('win32')
		let sep = '\'
	else
		let sep = '/'
	endif
	return sep
	
endfunction

function! base#file#std( filename,... )
	let fname = a:filename

	if a:0
		let sep = a:1
	else
		let sep = base#file#sep()
	endif

	let pc = split(fname,sep)
	let rpc = reverse(copy(pc))

	let rm = 0
	let npc=[]
	while len(rpc)
		let p = remove(rpc, 0)
		if p == ".." 
			let rm+=1
		else
			if ( rm > 0 )
				let rm-=1
			else
				call add(npc,p)
			endif
		endif
	endw
	let pc = reverse(npc)

	let fname = join(pc,sep)
	return fname

endf


function! base#file#unix2win( filename )
	let fname = a:filename

	if has('win32')
		return substitute(fname,'/','\','g')
	endif

	return fname

endf

function! base#file#ossep( filename )
	let fname = a:filename

	if has('win32')
		return base#file#unix2win(fname) 
	else
		return base#file#win2unix(fname) 
	endif

endf

function! base#file#win2unix( filename )

	if has('win32')
		return substitute(a:filename,'\\','/','g')
	endif

	return a:filename

endf
 

