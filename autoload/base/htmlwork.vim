
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

function! base#htmlwork#log_debug ()
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

function! base#htmlwork#log_warnings ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,func,url,msg,details FROM log where loglevel in (?)'
	let q = input('query:',q)
	let p = [ 'warn' ]

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})

	call base#buf#open_split({ 'lines' : lines })
	
endfunction

function! base#htmlwork#fails ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,msg,url,details FROM log where msg = ?'
	let p = ['FAIL']

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})

	call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#htmlwork#debug_vars ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,func,url,msg,var_name,var_value,details FROM log where loglevel = ?'
	let q = input('query:',q)
	let p = ['debug']

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})

	call base#buf#open_split({ 'lines' : lines })

endfunction


function! base#htmlwork#clear_log ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'DELETE FROM log'

	call pymy#sqlite#query({
		\	'dbfile' : dbfile,
		\	'q'      : q,
		\	})

endfunction

function! base#htmlwork#delete_saved_files ()
	let dbfile = base#htmlwork#dbfile()

	if !yn
		return
	endif

	let q = 'SELECT local FROM saved'
	let p = []
	
	let saved_files = pymy#sqlite#query_as_list({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})
	for sfile in saved_files
		if filereadable(sfile)
			call delete(sfile)
		endif
	endfor

endfunction

function! base#htmlwork#clear_saved ()
	let dbfile = base#htmlwork#dbfile()

	let yn = input('Ready to delete saved? 1/0:',1)

	if !yn
		return
	endif

	let q = 'SELECT local FROM saved'
	let p = []
	
	let saved_files = pymy#sqlite#query_as_list({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})
	for sfile in saved_files
		if filereadable(sfile)
			call delete(sfile)
		endif
	endfor

	let q = 'DELETE FROM saved'
	let q = input('query:',q)

	call pymy#sqlite#query({
		\	'dbfile' : dbfile,
		\	'q'      : q,
		\	})

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

function! base#htmlwork#href ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,url FROM href'
	let q = input('query:',q)

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
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

	let q = 'SELECT rowid,remote,local FROM saved'
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

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'p'      : p,
		\	'q'      : q,
		\	})
	call base#buf#open_split({ 'lines' : lines })
endfunction
