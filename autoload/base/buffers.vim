 
fun! base#buffers#get(...)

  redir => lsvar 
  silent ls
  redir END 

  let blines    = split(lsvar,"\n")
  let bufnums = []

  " Contains buffer structures
  let bufs=[]
  let bufh=[]

  for bline in blines
     let struct = split(bline,' ')

     let bnum   = struct[0]
     let file   = struct[6]

     call add(bufs,struct)
     call add(bufnums,bnum)

	 "let file = struct[]
	 let h={ 'num' : bnum, 'file' : file}

     call add(bufh,h)
  endfor

  call base#var('bufs',bufs)
  call base#var('bufh',bufh)

  call base#var('bufnums',bufnums)
 
endfun
  
fun! base#buffers#list(...)
  call base#buffers#get()

  call base#varecho('bufh')
  call base#varecho('bufnums')
  call base#varecho('bufs')
 
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
 
 
