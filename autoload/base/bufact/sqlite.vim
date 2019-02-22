
function! base#bufact#sqlite#show_tables ()
	call base#buf#start()

	let db_file = b:file
	let tables = []

python << eof

import sqlite3
import re
import os
import vim

db_file = vim.eval('db_file')
conn = sqlite3.connect(db_file)
c = conn.cursor()

q='''
		SELECT 
			name 
		FROM 
			sqlite_master
		WHERE 
			type IN ('table','view') AND name NOT LIKE 'sqlite_%'
		UNION ALL
		SELECT 
			name 
		FROM 
			sqlite_temp_master
		WHERE 
			type IN ('table','view')
		ORDER BY 1'''

c.execute(q)
tables = c.fetchall()

conn.commit()
conn.close()

for table in tables:
	vim.command("let table = '" + table + "'")
	vim.command('call add(tables,table)')
	
eof
	call base#buf#open_split({ 'lines' : tables })
endfunction
