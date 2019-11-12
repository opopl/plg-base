 


fun! base#buffers#get()

  redir => lsvar 
  silent ls!
  redir END 

  let blines  = split(lsvar,'\n')

  let bufnums = []
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
        let b = { "attr" : bits[0], "line": substitute(bits[-1], '\s*', '', '')}

        let name = bufname(str2nr(b.attr))
        let b["hasNoName"] = empty(name)
        if b.hasNoName
            let name = "[No Name]"
        endif

        for [key, val] in items(types)
            let b[key] = fnamemodify(name, val)
        endfor
				call add(buffiles, b.fullname)

        if getftype(b.fullname) == "dir" && base#opttrue('buf_showdirs')
            let b.shortname = "<DIRECTORY>"
        endif
	
				let attr_a = split(b.attr,'\s\+')
				let bnum   = str2nr( attr_a[0] )
		
				call extend(b,{ 'num' : bnum })
				call add(bufnums,bnum)

				call add(bufs, b)
				
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

	call base#varset('bufs',bufs)
	call base#varset('bufnums',bufnums)

	let bref = {
			\	'bufs'     : bufs,
			\	'buffiles' : buffiles,
			\	'bufnums'  : bufnums,
			\	}

	return bref

endfun

fun! base#buffers#fill_db(...)
	let dbfile  = base#dbfile()

	let sqlf   = base#qw#catpath('plg', 'base data sql create_table_buffers.sql')

	let sql    = join(readfile(sqlf),"\n")

	let bref =  base#buffers#get()
	
	call pymy#sqlite#query({
		\	'dbfile' : base#dbfile(),
		\	'q'      : sql,
		\	})

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
		\	'dbfile' : base#dbfile(),
		\	'q'      : q,
		\	})
	call base#buf#open_split({ 'lines' : lines })

endfun

fun! base#buffers#wipeall(...)
  let currnum = bufnr('%')

  for bnum in base#varget('bufnums',[])
     if bnum != currnum  
        exe 'bwipeout ' . bnum
				let q = 'DELETE FROM buffers WHERE num = ?'
				
				call pymy#sqlite#query({
					\	'dbfile' : base#dbfile(),
					\	'p'      : [ bnum ],
					\	'q'      : q,
					\	})
				
     endif
  endfor
 
endfun
 
 
