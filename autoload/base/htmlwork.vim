
function! base#htmlwork#log ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT rowid,func,url,msg FROM log WHERE loglevel IN (?,?)'
  let q = input('query:',q)
  let p = [ '' , 'log' ]

  let siteid = base#varget('htw_siteid','')
  let cond = ''
  if strlen(siteid)
    let cond = ' AND siteid = ? '
    call add(p,siteid)
  endif
  let q .= cond

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })

  call base#buf#open_split({ 'lines' : lines })
  
endfunction

function! base#htmlwork#local_index ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT rowid, vh_file, vh_tag, remote FROM local_index '
  let q = input('query:',q)
  let p = []

  let siteid = base#varget('htw_siteid','')
  let cond = ''
  if strlen(siteid)
    let cond = ' WHERE siteid = ? '
    call add(p,siteid)
  endif
  let q .= cond

  let q .= ' ORDER BY remote '

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })

  call base#buf#open_split({ 'lines' : lines })
  
endfunction

function! base#htmlwork#log_debug ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT rowid,func,url,msg FROM log WHERE loglevel in (?)'
  let q = input('query:',q)
  let p = [ 'debug' ]

  let siteid = base#varget('htw_siteid','')
  let cond = ''
  if strlen(siteid)
    let cond = ' AND siteid = ? '
    call add(p,siteid)
  endif
  let q .= cond

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })

  call base#buf#open_split({ 'lines' : lines })
  
endfunction

function! base#htmlwork#log_warnings ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT rowid,func,url,msg,details FROM log where loglevel in (?)'
  let q = input('query:',q)
  let p = [ 'warn' ]

  let siteid = base#varget('htw_siteid','')
  let cond = ''
  if strlen(siteid)
    let cond = ' AND siteid = ? '
    call add(p,siteid)
  endif
  let q .= cond

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })

  call base#buf#open_split({ 'lines' : lines })
  
endfunction

function! base#htmlwork#fails ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT rowid,msg,url,details FROM log where msg = ?'
  let p = ['FAIL']

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })

  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#htmlwork#warn_details ()
  let dbfile = base#htmlwork#dbfile()

  let qs = ['']
  let p = []
  
  call add(qs,'SELECT msg,details FROM log ' . 
    \   ' WHERE loglevel = ? ')

  call add(p,'warn')

  let q = get(qs,1,'')

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })

  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#htmlwork#debug_vars ()
  let dbfile = base#htmlwork#dbfile()

  let qs = ['']
  let p = []
  "call add(qs,'SELECT rowid,func,url,msg,var_name,var_value,details FROM log WHERE loglevel = ?')
  "call add(qs,'SELECT func,var_name,var_value FROM log WHERE loglevel = ?')
  "call add(qs,'SELECT details FROM log WHERE loglevel = ?')
  "
  call add(qs,'SELECT msg,var_name,var_value FROM log ' . 
    \ ' WHERE loglevel = ? AND var_name = "href_remote"')

 " call add(qs,'SELECT var_name, var_value, details FROM log ' 
    "\  . ' WHERE loglevel = ? AND func = "list_href" AND var_name = "@href_internal_only"' )

  call base#varset('this',qs)
  "let q = input('query:','','custom,base#complete#this')
  call add(p,'debug')

  let q = get(qs,1,'')

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })

  call base#buf#open_split({ 'lines' : lines })

endfunction


function! base#htmlwork#clear_log ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'DELETE FROM log'

  call pymy#sqlite#query({
    \ 'dbfile' : dbfile,
    \ 'q'      : q,
    \ })

endfunction

function! base#htmlwork#siteid_set ()
  let dbfile = base#htmlwork#dbfile()

  let siteid = base#input_we('select siteid: ','',{ 
    \ 'complete' : 'custom,idephp#complete#dws_siteids'
    \ })
  call base#varset('htw_siteid',siteid)

endfunction

function! base#htmlwork#siteid_delete ()
  let dbfile = base#htmlwork#dbfile()

  let siteid = base#input_we('siteid: ','',{ 
    \ 'complete' : 'custom,idephp#complete#dws_siteids'
    \ })

  let tables = base#qw('href log saved local_index')

  let msg_a = [' ']
  call add(msg_a,repeat('-',70))
  call add(msg_a,'This command will delete values from tables: ')
  call add(msg_a,"\t" . join(tables,' '))
  call add(msg_a,"for the following siteid:")
  call add(msg_a,"\t" . siteid)
  call add(msg_a,"Are you ready to delete? 1/0: ")

  let msg = join(msg_a,"\n")

  let yn = input(msg,0)
  if !yn | return | endif

  for t in tables
    let q = 'DELETE FROM ' . t  . ' WHERE siteid = ? ' 
    let p = [ siteid ]

    call pymy#sqlite#query({
      \ 'dbfile' : dbfile,
      \ 'p'      : p,
      \ 'q'      : q,
      \ })
  endfor

endfunction

function! base#htmlwork#siteids ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT DISTINCT siteid FROM saved'
  let p = [ ]
  
  let siteids = pymy#sqlite#query_as_list({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })
  return siteids

endfunction

function! base#htmlwork#info (...)
  let ref = get(a:000,0,{})

  let dbfile = base#htmlwork#dbfile()

  let info = []

  call pymy#sqlite#dbfile(dbfile)
  call extend(info, pymy#sqlite_cmd#info({ 'skip_split' : 1 }) )
  call add(info,'SITEID: ')
  call add(info,"\t".base#varget('htw_siteid',''))

  call base#buf#open_split({ 'lines' : info })
  return info

endfunction

function! base#htmlwork#delete_saved_files ()
  let dbfile = base#htmlwork#dbfile()

  let siteid = base#varget('htw_siteid','')

  let local_files = pymy#sqlite#query_as_list({
    \ 'dbfile' : dbfile,
    \ 'q'      : 'SELECT local FROM saved WHERE siteid = ?',
    \ 'p'      : [siteid],
    \ })

  let vh_files = pymy#sqlite#query_as_list({
    \ 'dbfile' : dbfile,
    \ 'q'      : 'SELECT vh_file FROM saved WHERE siteid = ?',
    \ 'p'      : [siteid],
    \ })

  let files = []
  call extend(files,vh_files)
  call extend(files,local_files)

  for sfile in files 
    if filereadable(sfile)
      call delete(sfile)
    endif
  endfor

endfunction

function! base#htmlwork#drop_all ()
  let dbfile = base#htmlwork#dbfile()

  let yn = input('Ready to drop all tables? 1/0: ', 1)
  if !yn | return | endif

  call base#htmlwork#delete_saved_files ()

  let tables = base#qw('href log saved local_index')
  for t in tables
    let q = 'DROP TABLE IF EXISTS ' . t
    call pymy#sqlite#query({
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ })
  endfor

endfunction


function! base#htmlwork#menus_add ()
  let cmds = base#varget('htmlwork',[])
  let cmds = sort(cmds)

  let lev = 25
  for cmd in cmds
    call base#menu#additem({
      \   'item'      :   '&HTMLWORK.&' . cmd,
      \   'tab'       :   cmd,
      \   'cmd'       :   'HTMLWORK ' . cmd,
      \   'lev'       :   lev,
      \   })
  endfor

endf

function! base#htmlwork#menus_remove ()
    try 
      exe 'aunmenu &HTMLWORK'
    catch
    endtry

endf

function! base#htmlwork#help ()
  let cmds = base#varget('htmlwork',[])
  let cmds = base#uniq(cmds)
  let cmds = sort(cmds)

  call base#buf#open_split({ 'lines' : cmds })

endf

function! base#htmlwork#render_cmds ()

  let desc = base#varget('desc_htmlwork',{})
  let cmds = base#varget('htmlwork',[])
  let info = []

  for cmd in cmds
    call add(info,[ cmd, get(desc, cmd, '') ])
  endfor

	let delim = repeat( 'x', 50 )

	let lines = []
	call extend(lines,['HTMLWORK'])
	call extend(lines,[
		\	delim,
		\	'base#htmlwork#render_cmds base#htmlwork',
		\	'base#dat_vis#open',
		\	delim,
		\	])

	call extend(lines,['HTMLWORK commands: '])
  call extend(lines, pymy#data#tabulate({
    \ 'data'    : info,
    \ 'headers' : base#qw('cmd description'),
    \ }))

  let cmds_pre = []
  call add(cmds_pre,'resize 99')
  call add(cmds_pre,'MM tgadd_all')
  "call add(cmds_pre,"vnoremap <buffer><silent> c :'<,'>call base#dat_vis#open()<CR>")

  let stl_add = [ 'V[ %1* c - call %0* ]' ]
	let stl_add = []

  call base#buf#open_split({ 
    \ 'lines'    : lines ,
    \ 'cmds_pre' : cmds_pre,
    \ 'stl_add'  : [],
    \ })
  return


endf

if 0
	BaseDatView htmlwork
endif

function! base#htmlwork#clear_all ()
  let dbfile = base#htmlwork#dbfile()

  let siteid = base#varget('htw_siteid','')

  let delim = repeat('-',50)

  let tables = base#qw('href log saved local_index')

  let msg  = ''
  let msg .= "\n"   . 'HTMLWORK clear_all ' 
  let msg .= "\n"   . delim
  let msg .= "\n"   . 'siteid = ' . siteid 
  let msg .= "\n"   . ' ' 
  let msg .= "\n"   . 'This will do the following: ' 
  let msg .= "\n"   . '- remove files' 
  let msg .= "\n"   . '- delete table rows for tables:' 
  let msg .= "\n"   . '    ' . join(tables,' ')
  let msg .= "\n"   . delim
  let msg .= "\n"   . 'Ready to delete everything? (1/0): '

  let yn = input(msg,0)
  if !yn | return | endif

  let p = []
  let cond = ''
  if strlen(siteid)
    let cond = ' WHERE siteid = ? '
    call add(p,siteid)
  endif

  call base#htmlwork#delete_saved_files()

  for t in tables
    let q  = 'DELETE FROM ' . t 
    let q .= cond

    call pymy#sqlite#query({
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : p,
      \ })
  endfor

endfunction


function! base#htmlwork#db_backup ()
  let dbfile = base#htmlwork#dbfile()
  
  let dirname  = fnamemodify(dbfile,':p:h')
  let basename = fnamemodify(dbfile,':p:t')
  
  let bdir = base#file#catfile([ dirname, 'backup' ])
  call base#mkdir(bdir)
  
  let bname = input('backup dbfile name: ',basename)
  
  let bfile = base#file#catfile([ bdir, bname ])
  call base#file#copy(dbfile,bfile) 
  
endfunction

function! base#htmlwork#db_restore ()

endfunction

function! base#htmlwork#url_level (url, url_base)
endfunction

function! base#htmlwork#sql_alterations ()
  let dbfile = base#htmlwork#dbfile()
  let qs = []
  "call add(qs,'ALTER TABLE href ADD COLUMN url_level INTEGER')
  "call add(qs,'ALTER TABLE href ADD COLUMN base_url TEXT')
  call add(qs,'ALTER TABLE saved ADD COLUMN href_done INTEGER')

  for q in qs
    call pymy#sqlite#query({
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ })
  endfor

endfunction

function! base#htmlwork#href ()
  let dbfile = base#htmlwork#dbfile()

  let qs = []
  "call add(qs,'SELECT rowid,url_parent,url_full,url_short FROM href')
  "call add(qs,'SELECT type,url_short FROM href')
  "call add(qs,'SELECT type,url_short,base_url FROM href')
  "call add(qs,'SELECT type,url_short,url_local,url_local_base FROM href')
  "call add(qs,'SELECT type,url_short,url_local_relative,url_local_base FROM href')
  call add(qs,'SELECT type,url_local FROM href')
  call add(qs,'')

  call base#varset('this',qs)
  let q = input('query:','','custom,base#complete#this')

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'q'      : q,
    \ })
  call base#buf#open_split({ 'lines' : lines })
endfunction

function! base#htmlwork#siteids ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT DISTINCT siteid FROM saved'
  let siteids = pymy#sqlite#query_as_list({
    \ 'dbfile' : dbfile,
    \ 'q'      : q,
    \ })
  return siteids
endfunction

function! base#htmlwork#view_saved ()
  let dbfile = base#htmlwork#dbfile()
  
  let siteids = base#htmlwork#siteids ()
  call base#varset('this',siteids)
  
  let siteid = base#input_we('siteid:','',{ 'complete' : 'custom,base#complete#this' })
  
  let q = 'SELECT local FROM saved WHERE siteid = ?'
  let p = [siteid]
  let files = pymy#sqlite#query_as_list({
    \ 'dbfile' : dbfile,
    \ 'q'      : q,
    \ 'p'      : p,
    \ })
  let files_h = {}
  for file in files
    let bname = fnamemodify(file,":p:t")
    call extend(files_h,{ bname : file })
  endfor

  call base#varset('this', sort(keys(files_h)) )
  let local_bname = base#input_we('local file:','',{ 'complete' : 'custom,base#complete#this' })

  let local = get(files_h, local_bname, '')

  call base#fileopen({ 
    \ 'files'    : [ local ],
    \ 'load_buf' : 1,
    \ })

endfunction

function! base#htmlwork#href_short ()
  let dbfile = base#htmlwork#dbfile()

  let q = 'SELECT rowid,url_parent,url_full,url_short FROM href'
  let q = input('query:',q)

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'q'      : q,
    \ })
  call base#buf#open_split({ 'lines' : lines })
endfunction

function! base#htmlwork#dbfile(...)
  let dbfile = get(a:000,0,'')

  if ! strlen(dbfile)
    let dbfile = base#qw#catpath('db','html_work.sqlite')
    let dbfile = base#varget('htmlwork_dbfile',dbfile)
  else
    call base#varset('htmlwork_dbfile',dbfile)
  endif

  return dbfile

  
endfunction

function! base#htmlwork#db_connect(...)
    let dbname = input('dbname:','','custom,base#complete#dbnames')
    
    let q = 'SELECT dbfile FROM dbfiles WHERE dbname = ? AND dbdriver = ?'
    let p = [ dbname , "sqlite" ]
    
    let list = pymy#sqlite#query_as_list({
      \ 'dbfile' : base#dbfile(),
      \ 'p'      : p,
      \ 'q'      : q,
      \ })
    let dbfile = get(list,0,'')

    call base#htmlwork#dbfile(dbfile)

endfunction

function! base#htmlwork#saved ()
  let dbfile = base#htmlwork#dbfile()

  let q = ' SELECT rowid, remote, local FROM saved '
  let q = input('query:',q)
  let np = input('number of params:',0)

  let p = []
  if np
     let i = 0
     while i<np
        let par = input('param '.#i . ' : ','')
        call add(p,par)
     endw
  endif

  let siteid = base#varget('htw_siteid','')
  if strlen(siteid)
    let cond = ' WHERE siteid = ? '
    call add(p,siteid)
  endif
  let q .= cond

  let lines = pymy#sqlite#query_screen({
    \ 'dbfile' : dbfile,
    \ 'p'      : p,
    \ 'q'      : q,
    \ })
  call base#buf#open_split({ 'lines' : lines })
endfunction
