
function! base#file#catfile( ... )
	
	if ! a:0 | return '' | endif

	if type(a:1) == type([])
			let pieces = a:1
			let sep = has('win32') ? '\' : '/'

			let pieces = map(pieces,'base#file#catfile(v:val)')

			return join(pieces,sep)

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


function! base#file#unix2win( filename )

	if has('win32')
		return substitute(a:filename,'/','\','g')
	endif

	return a:filename

endf

function! base#file#win2unix( filename )

	if has('win32')
		return substitute(a:filename,'\\','/','g')
	endif

	return a:filename

endf
 

