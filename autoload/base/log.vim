
function! base#log#view_split ()

	let dbfile = base#dbfile()

	let q = 'SELECT rowid,loglevel,elapsed,prf,plugin,func,msg FROM log ORDER BY elapsed ASC'
	let q = input('log view query: ',q)

	let rq = {
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	}
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
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	'p'      : p,
			\	}
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
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	'p'      : p,
			\	}
	let lines = []
	let delim = repeat('x',50)
	call extend(lines,[delim,'base#time_start():' , "\t" . base#time_start(),delim ])

	call extend(lines, pymy#sqlite#query_screen(rq))
	call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#log#create_table ()
	let dbfile = base#dbfile() 
	let sqlfile = base#plgdir() . '/data/sql/create_table_log.sql' 
python << eof
import vim
import os.path

dbfile = vim.eval('dbfile')
sqlfile = vim.eval('sqlfile')

conn = sqlite3.connect(dbfile)
c = conn.cursor()
	
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
python << eof
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
	let sub = 'base#log#'.cmd
	exe 'call ' . sub . '()'

endfunction
