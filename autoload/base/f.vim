
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
			call base#f#set({ fileid, filepath })
		endif
	endif
	
endfunction

function! base#f#set (ref)

  if ! exists("s:files") | let s:files={} | endif

    for [ fileid, file ] in items(a:ref) 
        let e = { fileid : file }
        call extend(s:files,e)
    endfor

endfun

fun! base#f#showfiles(...)
  if ! exists("s:files") | let s:files={} | endif

	echo s:files
endfun

fun! base#f#echo(...)
  let aa     = a:000
  let fileid = get(aa,0,'')

	if !strlen(fileid)
		call base#f#showfiles()
	endif

  let fpath  = base#f#path(fileid)
  echo fpath
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

