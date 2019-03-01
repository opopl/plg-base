

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

function! base#bufact#sqlite#show_tables ()
	call base#buf#start()
	call pymy#buf#sqlite_start()

	let dbfile = b:file
	let lines = []

python << eof

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

for table in tables:
	vim.command("let table = '" + table + "'")
	vim.command('call add(lines,table)')
	
eof
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
