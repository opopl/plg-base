

function! base#bufact#sqlite#table_info ()
	call base#buf#start()
	call pymy#buf#sqlite_start()

	let dbfile = b:file

	let table = input('table:','','custom,pymy#sqlite#complete_tables')

	let q = 'SELECT * FROM ' . table . ' LIMIT 1'

	let ref = {
		\	'q'      : q,
		\	'dbfile' : dbfile,
		\	}
	let [ rows_h, cols ] = pymy#sqlite#query(ref)

endf

function! base#bufact#sqlite#add_to_dbfiles ()
	call base#buf#start()
	call pymy#buf#sqlite_start()

	let dbfile_current = pymy#sqlite#dbfile()
	let dbname = fnamemodify(dbfile_current,':t:r')
	
	let t = "dbfiles"
	let h = {
		\	"dbfile"   : dbfile_current,
		\	"dbname"   : dbname,
		\	"dbdriver" : 'sqlite',
		\	}
	
	let ref = {
		\ "dbfile" : base#dbfile(),
		\ "i"      : "INSERT OR REPLACE",
		\ "t"      : t,
		\ "h"      : h,
		\ }
		
	call pymy#sqlite#insert_hash(ref)

	call pymy#sqlite#dbfile(dbfile_current)

endf

function! base#bufact#sqlite#show_tables ()
	call base#buf#start()
	call pymy#buf#sqlite_start()

	let dbfile = b:file
	let lines = []

python3 << eof

import vim
import sqlite3

dbfile = vim.eval('dbfile')
conn = sqlite3.connect(dbfile)
c = conn.cursor()

#q='''
#		SELECT 
#			name 
#		FROM 
#			sqlite_master
#		WHERE 
#			type IN ('table','view') AND name NOT LIKE 'sqlite_%'
#		UNION ALL
#		SELECT 
#			name 
#		FROM 
#			sqlite_temp_master
#		WHERE 
#			type IN ('table','view')
#		ORDER BY 1'''
q='''
		SELECT 
			name
		FROM 
			sqlite_master
		WHERE 
			type IN ('table','view') AND name NOT LIKE 'sqlite_%'
'''

c.execute(q)
tables = [r[0] for r in c.fetchall()]

conn.commit()
conn.close()

eof
	let lines = py3eval('tables')
	call base#buf#open_split({ 'lines' : lines })
endfunction

function! base#bufact#sqlite#query ()
	call base#buf#start()
	call pymy#buf#sqlite_start()

	let dbfile = pymy#sqlite#dbfile()

	let query = ''
	while !strlen(query)
		let query = input('query:','')
	endw
	let limit = input('limit:','10')

	if strlen(limit)
		let query .= ' LIMIT ' . limit 
	endif

	let lines = []
	let lines = pymy#sqlite#query_screen({ 
		\	'q'      : query,
		\	'dbfile' : dbfile
		\	})
	call base#buf#open_split({ 'lines' : lines })

endfunction
