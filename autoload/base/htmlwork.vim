
function! base#htmlwork#log ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,func,url,msg FROM log where loglevel in (?,?)'
	let q = input('query:',q)
	let p = [ '' , 'log' ]

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})

	call base#buf#open_split({ 'lines' : lines })
	
endfunction

function! base#htmlwork#debug ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,func,url,msg FROM log where loglevel in (?)'
	let q = input('query:',q)
	let p = [ 'debug' ]

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

function! base#htmlwork#saved ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,local,remote FROM saved'
	let q = input('query:',q)
	let p = []

	let sortcol = 0
	let sortcol = input('sortcol: ',sortcol)

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	'sortcol'      : sortcol,
		\	})
	call base#buf#open_split({ 'lines' : lines })
endfunction
