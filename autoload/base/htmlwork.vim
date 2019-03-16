
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

function! base#htmlwork#db_backup ()
	let dbfile = base#htmlwork#dbfile()

	let dirname  = fnamemodify(dbfile,':p:h')
	let basename = fnamemodify(dbfile,':p:t')

	let bdir = base#file#catfile([ dirname, 'backup' ])
	call base#mkdir(bdir)

	let bfile = base#file#catfile([ bdir, basename ])
	call base#file#copy(dbfile,bfile)	

endfunction

function! base#htmlwork#db_restore ()

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
	let np = input('number of params:',0)

	let p = []
	if np
		 let i = 0
		 while i<np
				let par = input('param '.#i . ' : ','')
				call add(p,par)
		 endw
	endif

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
