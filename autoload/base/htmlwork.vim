
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

	let qs = ['']
	"call add(qs,'SELECT rowid,func,url,msg,var_name,var_value,details FROM log WHERE loglevel = ?')
	"call add(qs,'SELECT func,var_name,var_value FROM log WHERE loglevel = ?')
	"call add(qs,'SELECT details FROM log WHERE loglevel = ?')

	call add(qs,'SELECT var_name, var_value, details FROM log ' 
		\	. ' WHERE loglevel = ? AND func = "list_href" AND var_name = "@href_internal_only"' )

	call base#varset('this',qs)
	"let q = input('query:','','custom,base#complete#this')
	let p = ['debug']

	let q = get(qs,1,'')


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

function! base#htmlwork#drop_all ()
	let dbfile = base#htmlwork#dbfile()

	let yn = input('Ready to drop all tables? 1/0: ',1)
	if !yn | return | endif

	let tables = base#qw('href log saved')
	for t in tables
		let q = 'DROP TABLE IF EXISTS ' . t
		call pymy#sqlite#query({
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	})
	endfor

endfunction

function! base#htmlwork#clear_all ()
	let dbfile = base#htmlwork#dbfile()

	let yn = input('Ready to delete everything? 1/0: ',1)
	if !yn | return | endif

	call base#htmlwork#delete_saved_files()
	let tables = base#qw('href log saved')
	for t in tables
		let q = 'DELETE FROM ' . t
		call pymy#sqlite#query({
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	})
	endfor

endfunction

function! base#htmlwork#clear_saved ()
	let dbfile = base#htmlwork#dbfile()

	let yn = input('Ready to delete saved? 1/0:',1)

	if !yn | return | endif

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

	let bname = input('backup dbfile name: ',basename)

	let bfile = base#file#catfile([ bdir, bname ])
	call base#file#copy(dbfile,bfile)	

endfunction

function! base#htmlwork#db_restore ()

endfunction

function! base#htmlwork#url_level (url,url_base)
endfunction

function! base#htmlwork#sql_alterations ()
	let dbfile = base#htmlwork#dbfile()
	let qs = []
	"call add(qs,'ALTER TABLE href ADD COLUMN url_level INTEGER')
	"call add(qs,'ALTER TABLE href ADD COLUMN base_url TEXT')
	call add(qs,'ALTER TABLE saved ADD COLUMN href_done INTEGER')

	for q in qs
		call pymy#sqlite#query({
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	})
	endfor

endfunction

function! base#htmlwork#href ()
	let dbfile = base#htmlwork#dbfile()

	let qs = []
	call add(qs,'SELECT rowid,url_parent,url_full,url_short FROM href')
	call add(qs,'SELECT type,url_short FROM href')
	call add(qs,'')

	call base#varset('this',qs)
	let q = input('query:','','custom,base#complete#this')

	let lines = pymy#sqlite#query_screen({
		\	'dbfile' : dbfile,
		\	'q'      : q,
		\	})
	call base#buf#open_split({ 'lines' : lines })
endfunction

function! base#htmlwork#href_short ()
	let dbfile = base#htmlwork#dbfile()

	let q = 'SELECT rowid,url_parent,url_full,url_short FROM href'
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
