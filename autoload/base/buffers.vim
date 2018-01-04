 
fun! base#buffers#get(...)

  redir => lsvar 
  silent ls!
  redir END 

  let blines  = split(lsvar,'\n')
  let bufnums = []

  let types=base#varget('buf_types',{})

  let [all, allwidths, listedwidths] = [[], {}, {}]

  for n in keys(types)
    let allwidths[n] = []
    let listedwidths[n] = []
  endfor

  " Contains buffer structures
  let bufs=[]
  let bufh=[]

  for buf in blines
        let bits = split(buf, '"')

        " Use first and last components after the split on '"', in case a
        " filename with an embedded '"' is present.
        let b = {"attr": bits[0], "line": substitute(bits[-1], '\s*', '', '')}

        let name = bufname(str2nr(b.attr))
        let b["hasNoName"] = empty(name)
        if b.hasNoName
            let name = "[No Name]"
        endif

        for [key, val] in items(types)
            let b[key] = fnamemodify(name, val)
        endfor

        if getftype(b.fullname) == "dir" && base#opttrue('buf_showdirs')
            let b.shortname = "<DIRECTORY>"
        endif

		let attr_a=split(b.attr,'\s\+')
		let bnum=str2nr( attr_a[0] )
		call extend(b,{ 'num' : bnum })
		call add(bufnums,bnum)

        call add(all, b)

        for n in keys(types)
            call add(allwidths[n], base#sw(b[n]))

            if b.attr !~ "u"
                call add(listedwidths[n], base#sw(b[n]))
            endif
        endfor
	endfor

    let [allpads, listedpads] = [{}, {}]

    for n in keys(types)
        let allpads[n]    = repeat(' ', max(allwidths[n]))
        let listedpads[n] = repeat(' ', max(listedwidths[n]))
    endfor

	call base#varset('buf_allpads',allpads)
	call base#varset('buf_listedpads',listedpads)

	call base#varset('bufs',all)
	call base#varset('bufnums',bufnums)

endfun

fun! base#buffers#list(...)
  call base#buffers#get()

  call base#varecho('bufs')

  return
 
endfun

 
fun! base#buffers#wipeall(...)
  call base#buffers#get()

  let currnum=bufnr('%')

  for bnum in base#varget('bufnums',[])
     if bnum != currnum  
        exe 'bwipeout ' . bnum
     endif
  endfor
 
endfun
 
 
