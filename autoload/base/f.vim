

function! base#f#view (...)
	let fileid = get(a:000,0,'')

	if !strlen(fileid)
		let fileid = input('Fileid:','','custom,base#complete#fileids')
	endif

	let fp = base#f#path(fileid)

	if base#type(fp)=='List'
		let files = fp

	elseif base#type(fp)=='String'
		let files = [ fp ]

	endif

	call base#fileopen({ 'files' : files })

endfunction

function! base#f#add (...)
  if ! exists("s:files") | let s:files={} | endif

	let opt = get(a:000,0,'')

	if opt == 'thisfile'
		let filepath     = expand('%:p')
		let bname        = expand('%:p:t')

		let fileid = substitute(bname,'\.','_','g')

		let fileid = input('Suggested fileid:',fileid,'custom,base#complete#fileids')

		let lines=[]

		call add(lines,		'-----------------------')
		call add(lines,		 'File data to be added:')
		call add(lines,		 '   '.fileid)
		call add(lines,		 '   '.filepath)
		call add(lines,		 '-----------------------')

		let text = join(lines,"\n")."\n"

		call base#echo({ 'text' : text, 'prefix' : '' })

		let cnt = input('Continue? (1/0):',1)

		if cnt
			call base#f#set({ fileid : filepath })
		endif
	endif
	
endfunction

function! base#f#files ()
  if ! exists("s:files") | let s:files={} | endif
	return s:files
endfunction

function! base#f#set (ref)

  if ! exists("s:files") | let s:files={} | endif

  for [ fileid, file ] in items(a:ref) 
		 if type(file) == type('') && !filereadable(file)
				continue
		 endif

     let e = { fileid : file }
     call extend(s:files,e)
  endfor

  call base#varset('exefiles',s:files)
  call base#varset('exefileids',sort(keys(s:files)))

	call base#var#update('fileids')

endfun

"call base#f#run (fileid)

function! base#f#run (...)
	let fileid = get(a:000,0,'')
	let files  = get(s:files,fileid,[])

	for file in files
		" code
	endfor
	
endfunction

fun! base#f#showfiles(...)
  if ! exists("s:files") | let s:files={} | endif

	echo s:files
endfun

fun! base#f#echo_fpath(fpath)
	let l=[]

	if type(a:fpath)==type('')
		call add(l,'Exe full path: ' . a:fpath)
		call add(l,'Exe exists:    ' . ( filereadable(a:fpath)  ? 'YES' : 'NO' ))

	elseif type(a:fpath)==type([])
		let num=1
		for f in a:fpath
			call add(l,'EXE '.num)
			call extend(l,map(base#f#echo_fpath(f),"substitute(v:val,'^','\\t','g')"))
			let num+=1
		endfor

	endif

	return l
endfun

fun! base#f#echo(...)
  let aa     = a:000
  let fileid = get(aa,0,'')

	if !strlen(fileid)
		call base#f#showfiles()
	endif

  let fpath  = base#f#path(fileid)

	let l=[]
	call add(l,'      ')
	call add(l,'Exe id:        ' . fileid)
	call extend(l,base#f#echo_fpath(fpath))
	call add(l,'      ')

	call base#buf#open_split({ 'lines' : l})
endf

"echo base#f#path('perl')
"echo base#f#path('perl',0)
"echo base#f#path('perl',1)

fun! base#f#path(...)
  let aa=a:000

  if ! exists("s:files") | let s:files={} | endif

  let fileid = get(aa,0,'')
  let index  = get(aa,1,'')

  let fpath  = get(s:files,fileid,'')

  if type(fpath) == type([])
     if len(index)
       let p = get(fpath,index,'')
       return p
     endif
  endif

  return fpath
endf

