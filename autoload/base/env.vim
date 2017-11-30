
function! base#env#echo (...)
	let var = get(a:000,0,'')
	if !len(var) | return | endif

	if var == 'PATH'
	endif
	
	
endfunction

function! base#env#init (...)

endfunction

function! base#env#path (...)
	if has('win32')
		let pat   = '^PATH=\(.*\)$'
		let lines = base#splitsystem("set path")
		let path  = ''

		for l in lines
			if l=~'^PATH='
				let path = substitute(l,pat,'\1','g')
			endif
		endfor

	endif
	return path

endfunction

function! base#env#path_a (...)
	let path = base#env#path()
	if has('win32')
		let path_a = split(path,";")
	endif

	return path_a

endfunction

function! base#env#path_splitline (...)

	let path_a  = base#env#path_a()
	let path_sl = join(path_a,"\n")

	return path_sl

endfunction

function! base#env#path_append ()
	
endfunction

"C:\Users\apoplavskiy\programs\ctags58;C:\Users\apoplavskiy\programs\gtags\bin;C:\Users\apoplavskiy\programs\exiv2;C:\Users\apoplavskiy\programs\eclipse;C:\Users\apoplavskiy\programs\mingw\bin;C:\Users\apoplavskiy\bin;C:\Users\apoplavskiy\bin;C:\Program Files\Java\jdk-9\bin;C:\Users\apoplavskiy\programs\maven\bin;C:\OSPanel\modules\database\MySQL-5.7-x64\bin;C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin;C:\Program Files (x86)\IrfanView;C:\Users\apoplavskiy\programs\perl\strawberry_522_32bit\perl\bin;C:\texlive\2015\bin\win32;C:\Ruby22\bin;C:\Resource Tuner Console;C:\Resource Tuner Console
