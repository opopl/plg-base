
function! base#bufact#sqlite#show_tables ()
	call base#buf#start()

	let dbfile = b:file
	let lines = []

python << eof

import vim
import sqlite3

dbfile = vim.eval('dbfile')
conn = sqlite3.connect(dbfile)
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

	let dbfile = b:file
	let query = input('query:','')
	let limit = input('limit:','10')

	if strlen(limit)
		let query .= ' limit ' . limit 
	endif

	let lines = []

python << eof

import vim
import sqlite3

from tabulate import tabulate
from collections import deque

dbfile = vim.eval('dbfile')
query = vim.eval('query')

conn = sqlite3.connect(dbfile)
c = conn.cursor()

c.execute(query)
rows = c.fetchall()
desc = map(lambda x: x[0], c.description)
t = tabulate(rows,headers = desc)
lines = deque(t.split("\n"))

lines.extendleft([ 'Query:', "\t" + query ])

conn.commit()
conn.close()

for line in lines:
	vim.command("let line = '" + line + "'")
	vim.command('call add(lines,line)')
	
eof
	call base#buf#open_split({ 'lines' : lines })

endfunction
