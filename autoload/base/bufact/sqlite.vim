
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

for table in tables:
	q='''SELECT * FROM ''' + table 


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
import re

from tabulate import tabulate
from collections import deque

dbfile = vim.eval('dbfile')
query = vim.eval('query')

conn = sqlite3.connect(dbfile)
c = conn.cursor()

c.execute(query)
rows = c.fetchall()
desc = map(lambda x: re.escape(x[0]), c.description)
t = tabulate(rows,headers = desc)
lines = deque(t.split("\n"))

h = [ 'DATABASE', "\t" + re.escape(dbfile), 'QUERY:', "\t" + query, 'OUTPUT:' ]
lines.extendleft(reversed(h))

conn.commit()
conn.close()

for line in lines:
	line_e = re.escape(line).replace('\\\\', '\\')
	vim.command("let line = " + '"' + line_e + '"')
	vim.command('call add(lines,line)')
	
eof
	call base#buf#open_split({ 'lines' : lines })

endfunction
