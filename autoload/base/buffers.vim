 

fun! base#buffers#get_Fc_with(self,with)
  let self = a:self

  let this = deepcopy(self)

  let with = a:with

  let root = get(with,'root','')
  let root = base#file#win2unix(root)

  let file_full = get(with,'file_full','')
  let file_full = base#file#win2unix(file_full)

  let file_basename = get(with,'file_basename','')

  let buffiles = []
  let bufnums  = []
  let bufs     = []

  for b in self.bufs
      let fullname = get(b,'fullname','')
      let fullname = base#file#win2unix(fullname)
      
      let ok = 1 

      if strlen(root)
        let ok = ok 
          \ && strlen(fullname)
          \ && filereadable(fullname)
          \ && strlen(base#file#reldir(fullname,root))
      endif

      if strlen(file_basename)
        let ok = ok 
          \ && strlen(fullname)
          \ && ( fnamemodify(fullname,':t') == file_basename )
      endif

      if strlen(file_full)
        let ok = ok 
          \ && strlen(fullname)
          \ && ( fullname == file_full )
      endif

      if ok
        call add(buffiles,fullname)
        call add(bufs, b)
        call add(bufnums, b.num)
      endif
    endfor

    let this.bufs     = bufs
    let this.bufnums  = bufnums
    let this.buffiles = buffiles

    return this

endf

fun! base#buffers#get(...)
  let ref = get(a:000,0,{})

  redir => lsvar 
  silent ls!
  redir END 

  let with = get(ref,'with',{})

  let blines  = split(lsvar,'\n')

  let bufnums  = []
  let buffiles = []

  let types = base#varget('buf_types',{})

  let [ allwidths, listedwidths] = [ {}, {} ]

  for n in keys(types)
    let allwidths[n]    = []
    let listedwidths[n] = []
  endfor

  " Contains buffer structures
  let bufs = []
  let bufh = []

  for buf in blines
     let bits = split(buf, '"')

     " Use first and last components after the split on '"', in case a
     " filename with an embedded '"' is present.
     let b = { 
            \ "attr" : bits[0], 
            \ "line" : substitute(bits[-1], '\s*', '', ''),
            \ }

     let name = bufname(str2nr(b.attr))
     let b["hasNoName"] = empty(name)
     if b.hasNoName
         let name = "[No Name]"
     endif

     for [ key, val ] in items(types)
         let b[key] = fnamemodify(name, val)
         let b[key] = base#file#win2unix(b[key])
     endfor

     if getftype(b.fullname) == "dir" && base#opttrue('buf_showdirs')
         let b.shortname = "<DIRECTORY>"
     endif
 
     let attr_a = split(b.attr,'\s\+')
     let bnum   = str2nr( attr_a[0] )
 
     call extend(b,{ 'num' : bnum })
     
     for n in keys(types)
         call add(allwidths[n], base#sw(b[n]))

         if b.attr !~ "u"
             call add(listedwidths[n], base#sw(b[n]))
         endif
     endfor

     call add(bufs, b)
     call add(buffiles, b.fullname)
     call add(bufnums,bnum)
  endfor

  let [allpads, listedpads] = [{}, {}]

  for n in keys(types)
    let allpads[n]    = repeat(' ', max(allwidths[n]))
    let listedpads[n] = repeat(' ', max(listedwidths[n]))
  endfor

  call base#varset('buf_allpads',allpads)
  call base#varset('buf_listedpads',listedpads)

  call base#varset('bufs',bufs)
  call base#varset('bufnums',bufnums)

  let bref = {
      \ 'bufs'     : bufs,
      \ 'buffiles' : buffiles,
      \ 'bufnums'  : bufnums,
      \ }

  function! bref.with (with) dict
    let this = base#buffers#get_Fc_with(self,a:with)
    return this
  endfunction
 
  return bref

endfun

fun! base#buffers#fill_db(...)
  let dbfile  = base#dbfile()

  let sqlf   = base#qw#catpath('plg', 'base data sql create_table_buffers.sql')

  let sql    = join(readfile(sqlf),"\n")

  let bref =  base#buffers#get()
  
  call pymy#sqlite#query({
    \ 'dbfile' : base#dbfile(),
    \ 'q'      : sql,
    \ })

  let bufs = base#varget('bufs',[])
  for buf in bufs
      let ref = {
          \ "dbfile" : dbfile,
          \ "i"      : "INSERT OR REPLACE",
          \ "t"      : 'buffers',
          \ "h"      : buf,
          \ }
          
      let [ rowid ] = pymy#sqlite#insert_hash(ref)
  endfor

endfun

fun! base#buffers#file_is_loaded(file)  
  let file     = a:file

  let file = base#file#win2unix(file)

  let bref     = base#buffers#get()
  let buffiles = get(bref, 'buffiles', [])

  return base#inlist(file, buffiles)

endfun


fun! base#buffers#cmd(...)
  let cmd = get(a:000,0,'')

  let cmds = base#varget('cmds_BYFF',[])

  let sub = 'call base#buffers#'.cmd.'()'
  exe sub

endfun

"""BUFF_list
fun! base#buffers#list()

  let id   = get(a:000,0,'')
  let bufs = base#varget('bufs',[])

  let q = 'SELECT num, path FROM buffers'
  let q = input('query:',q)

  let dbfile  = base#dbfile()

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : base#dbfile(),
    \ 'q'      : q,
    \ })
  call base#buf#open_split({ 'lines' : lines })

endfun

fun! base#buffers#wipeall(...)
  let currnum = bufnr('%')

  for bnum in base#varget('bufnums',[])
     if bnum != currnum  
        exe 'bwipeout ' . bnum
        let q = 'DELETE FROM buffers WHERE num = ?'
        
        call pymy#sqlite#query({
          \ 'dbfile' : base#dbfile(),
          \ 'p'      : [ bnum ],
          \ 'q'      : q,
          \ })
        
     endif
  endfor
 
endfun
 
 
