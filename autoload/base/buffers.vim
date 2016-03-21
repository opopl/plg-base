 
fun! base#buffers#get(...)

  redir => lsvar 
  silent ls
  redir END 

  let blines    = split(lsvar,"\n")
  let g:bufnums = []

  " Contains buffer structures
  let g:bufs=[]

  for bline in blines
     let struct = split(bline,' ')
     let bnum   = struct[0]
     call add(g:bufs,struct)
     call add(g:bufnums,bnum)

  endfor
 
endfun
  
fun! base#buffers#list(...)
  call base#buffers#get()

  echo '--------------'
  echo 'g:bufs= '
  echo  g:bufs

  echo '--------------'
  echo 'g:bufnums=' 
  echo  g:bufnums
 
endfun

 
fun! base#buffers#wipeall(...)
  call base#buffers#get()

  let currnum=bufnr('%')

  for bnum in g:bufnums
     if bnum != currnum  
        exe 'bwipeout ' . bnum
     endif
  endfor
 
endfun
 
 
