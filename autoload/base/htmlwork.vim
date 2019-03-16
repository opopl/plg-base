
function! base#htmlwork#log ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'select rowid,func,url,msg from log'
	let q = input('query:',q)
	let p = []

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})

	call base#buf#open_split({ 'lines' : lines })
	
endfunction

function! base#htmlwork#dbfile()
	let dbfile = base#qw#catpath('db','html_work.sqlite')
	return dbfile
	
endfunction

