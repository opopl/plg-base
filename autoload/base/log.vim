
if 0
  call tree
    calls
      pymy#sqlite#query_screen
      base#buf#open_split
endif

function! base#log#view_split ()

  let dbfile = base#dbfile()

  let f_a = base#qw('prf plugin func msg')
  let f_s = join(f_a, ',')

  let q = printf('SELECT %s FROM log ORDER BY elapsed ASC',f_s)
  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ }
  let lines = []
  let delim = repeat('x',50)
  call extend(lines,[delim,'base#time_start():' , "\t" . base#time_start(),delim ])

  call extend(lines, pymy#sqlite#query_screen(rq))
  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#warnings ()
  let dbfile = base#dbfile()

  let q = 'SELECT rowid,elapsed,prf,plugin,func,msg FROM log WHERE loglevel = ?'
  let p = [ 'warn' ]
  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : p,
      \ }
  let lines = []
  let delim = repeat('x',50)
  call extend(lines,[delim,'base#time_start():' , "\t" . base#time_start(),delim ])

  call extend(lines, pymy#sqlite#query_screen(rq))
  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#func ()
  let dbfile = base#dbfile()

  let func = input('vim function: ','','custom,base#complete#log_func')

  let q = 'SELECT prf,plugin,func,msg FROM log ' 
  let q .= ' WHERE func = ? '

  let p = [ func ]
  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : p,
      \ }
  let lines = []
  let delim = repeat('x',50)
  call extend(lines,[delim,'base#time_start():' , "\t" . base#time_start(),delim ])

  call extend(lines, pymy#sqlite#query_screen(rq))
  call base#buf#open_split({ 'lines' : lines })

endfunction


function! base#log#_plg (...)
  let plg = get(a:000,0,'')

  let dbfile = base#dbfile()

  let q = 'SELECT prf,func,msg,vim_code FROM log ' 
  let q .= ' WHERE plugin = ?'

  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : [ plg ],
      \ }

  let lines = []
  call extend(lines, pymy#sqlite#query_screen(rq) )
  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#perl ()
  let dbfile = base#dbfile()

  let q = 'SELECT msg,prf,plugin,func,vim_code FROM log ' 
  let q .= ' WHERE prf = "vim::perl"'

  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : [],
      \ }

  let lines = []
  call extend(lines, pymy#sqlite#query_screen(rq) )
  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#vim_code ()
  let dbfile = base#dbfile()

  let q = 'SELECT prf,plugin,func,vim_code FROM log ' 
  let q .= ' WHERE length(vim_code) > 0'

  let p = []
  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : p,
      \ }

  let lines = []
  call extend(lines, pymy#sqlite#query_screen(rq) )
  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#v_exception ()
  let dbfile = base#dbfile()

  let q = 'SELECT prf,plugin,func,msg,v_exception FROM log ' 
  let q .= ' WHERE loglevel = ? AND length(v_exception) > 0'

  let p = [ 'warn' ]
  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : p,
      \ }
  let lines = []
  let delim = repeat('x',50)
  call extend(lines,[delim,'base#time_start():' , "\t" . base#time_start(),delim ])

  call extend(lines, pymy#sqlite#query_screen(rq))
  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#debug ()
  let dbfile = base#dbfile()

  let q = 'SELECT rowid,elapsed,prf,plugin,func,msg FROM log WHERE loglevel = ?'
  let p = [ 'debug' ]
  let q = input('log view query: ',q)

  let rq = {
      \ 'dbfile' : dbfile,
      \ 'q'      : q,
      \ 'p'      : p,
      \ }
  let lines = []
  let delim = repeat('x',50)
  call extend(lines,[delim,'base#time_start():' , "\t" . base#time_start(),delim ])

  call extend(lines, pymy#sqlite#query_screen(rq))
  call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#create_table ()
  let dbfile = base#dbfile() 
  let sqlfile = base#plgdir() . '/data/sql/create_table_log.sql' 
python3 << eof
import vim
import os.path

dbfile  = vim.eval('dbfile')
sqlfile = vim.eval('sqlfile')

conn = sqlite3.connect(dbfile)
c    = conn.cursor()
  
q = '''DROP TABLE IF EXISTS log'''
c.execute(q)

if os.path.isfile(sqlfile):
  with open(sqlfile) as f:
    q = f.read()
    c.execute(q)

conn.commit()
conn.close()
eof

endfunction


function! base#log#clear ()
  call base#varset('base_log',[])

  let dbfile = base#dbfile() 
python3 << eof
import vim

dbfile = vim.eval('dbfile')

conn = sqlite3.connect(dbfile)
c = conn.cursor()
  
q = '''DELETE FROM log'''
c.execute(q)

conn.commit()
conn.close()
eof

endfunction

function! base#log#cmd (...)
  let cmd = get(a:000,0,'view_split')

  let sub  = ''
  let args = ''

  if cmd =~ 'plg_\(\w\+\)$'
    let plg = substitute(cmd,'plg_\(\w\+\)$','\1','g')
    let sub = 'base#log#_plg'
    let args = printf('"%s"',plg)
  else
    let sub = 'base#log#'.cmd
  endif

  exe printf('call %s(%s)', sub, args)

endfunction
