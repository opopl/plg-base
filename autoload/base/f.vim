
function! base#f#add (...)
  if ! exists("s:files") | let s:files={} | endif
	
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

