
function! base#db#file_add (...)
		let ref    = get(a:000,0,{})

		let dbfile = base#dbfile()

		let file   = get(ref,'file','')
		let fileid = get(ref,'fileid','')
		
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

function! base#db#file_path (...)
		let ref    = get(a:000,0,{})
		
		let dbfile = base#dbfile()
		
		let fileid = get(ref,'fileid','')
		
		let dbfile = base#dbfile()
		
		let q = 'SELECT file FROM files WHERE fileid = ? '
		let p = [fileid]
		
		let file = pymy#sqlite#query_fetchone({
			\	'dbfile' : dbfile,
			\	'p'      : p,
			\	'q'      : q,
			\	})
		return file
endfunction
