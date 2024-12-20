
function! base#db#file_add (...)
		let ref    = get(a:000,0,{})

		let file   = get(ref,'file','')
		let fileid = get(ref,'fileid','')

		let dbfile = base#dbfile()
		
		let [ rowid ] = pymy#sqlite#insert_hash({
			\	'dbfile' : dbfile,
			\	't'      : 'files',
			\	'h'      : {
					\	'fileid' : fileid,
					\	'file'   : file,
					\	'pcname' : base#pcname(),
					\	},
			\	'i' : 'INSERT OR REPLACE',
			\	})
			
		return rowid
	
endfunction

function! base#db#file_path (fileid)
		let fileid = a:fileid

		let dbfile = base#dbfile()

		let pcname = base#pcname()
		
		let q = 'SELECT file FROM files WHERE fileid = ? AND pcname = ? '
		let p = [ fileid, pcname ]
		
		let file = pymy#sqlite#query_fetchone({
			\	'dbfile' : dbfile,
			\	'p'      : p,
			\	'q'      : q,
			\	})
		return file
endfunction

function! base#db#file_ids ()
		let dbfile = base#dbfile()
		
		let q = 'SELECT DISTINCT fileid FROM files WHERE pcname = ? '
		let p = [base#pcname()]
		
		let ids = pymy#sqlite#query_as_list({
			\	'dbfile' : dbfile,
			\	'p'      : p,
			\	'q'      : q,
			\	})
		return ids
endfunction
