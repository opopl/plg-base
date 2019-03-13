
"""sqlite_list_plugins
function! base#sqlite#list_plugins ()
	call base#init#sqlite()

	let p=[]
perl << eof
	my @p = $plgbase->db_list_plugins;
	VimListExtend('p',\@p);
eof
	call base#buf#open_split({ 'lines' : p })
	
endfunction

"BaseAct sqlite_list_keys_datfiles
"""sqlite_list_keys_datfiles
function! base#sqlite#list_keys_datfiles ()
	call base#init#sqlite()

	let k=[]
perl << eof
	use Base::DB qw(dbh_select);

	$Base::DB::DBH  = $plgbase->dbh;
	$Base::DB::WARN = sub { VimWarn(@_) };

	my $rows = dbh_select({ 
		t => 'datfiles',
		f => [qw( plugin key datfile )],
		cond => q{limit 10},
	});

	VimMsg(Dumper($rows));

	my $k=[];
	VimListExtend('k',$k);
eof
	let k=sort(k)
	call base#buf#open_split({ 'lines' : k })
	
endfunction

"""sqlite_list_datfiles
function! base#sqlite#list_datfiles ()
	call base#init#sqlite()

	let q = 'select plugin, key, keyfull, datfile from datfiles'
	let lines =  pymy#sqlite#query_screen({
		\	'q'      : q,
		\	'dbfile' : base#dbfile(),
		\	})
	call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#sqlite#datfiles (...)
	call base#init#sqlite()

	let kf  = get(a:000,0,'')
	let ref = get(a:000,1,{})

	let plugin = get(ref,'plugin','')
	let type   = get(ref,'type','')

	let q = ''
	let p = []
	if strlen(kf)
		let q = 'SELECT datfile FROM datfiles WHERE keyfull = ?'
		let p = [ kf ]
	else
		let q = 'SELECT keyfull, datfile FROM datfiles'
		let p = []
	endif

	let fw = keys(ref) 
	let vals = []
	for ff in fw
		call add(vals,get(ref,ff,''))
	endfor
	let fw_q = base#mapsub(fw,'$',' = ?','g')
	let cond = join(fw_q,' AND ')

	call extend(p,vals)

	if strlen(cond)
		if !strlen(kf)
			let cond = ' WHERE ' . cond
		endif
	endif
	let q .= cond

	let [ rows_h, cols ] =  pymy#sqlite#query({
		\	'q' : q,
		\	'p' : p,
		\	'dbfile' : base#dbfile(),
		\	})

	if strlen(kf)
		let datlist = []
		for rh in rows_h
				call add(datlist,get(rh,'datfile',''))
		endfor
		return datlist
	else
		let datfiles = {}
		for rh in rows_h
			let kf = get(rh,'keyfull','')
			let df = get(rh,'datfile','')
			if strlen(kf)
				call extend(datfiles,{ kf : df })
			endif
		endfor
		return datfiles

	endif

endfunction

function! base#sqlite#datlist ()
	call base#init#sqlite()

	let q = 'select keyfull from datfiles'
	let [ rows_h, cols ] =  pymy#sqlite#query({
		\	'q' : q,
		\	'dbfile' : base#dbfile(),
		\	})
	let list = []
	for rh in rows_h
			call add(list,get(rh,'keyfull',''))
	endfor
	return list

endfunction

function! base#sqlite#info (...)
	call base#init#sqlite()

	let ref    = get(a:000,0,{})
	let prompt = get(ref,'prompt',0)

	let info = []

	if prompt
	else
		call extend(info,base#sqlite#info_dbfile())
		call extend(info,base#sqlite#info_commands())
		call extend(info,base#sqlite#info_tables())
	endif

	call base#buf#open_split({ 'lines' : info })
	return 1

endfunction

function! base#sqlite#db_connect (...)
	call base#init#sqlite()

	let dbfile = input('dbfile:','','custom,base#complete#sqlite_dbfiles')
perl << eof
	my $dbfile = VimVar('dbfile');
	$plgbase->db_connect($dbfile);
eof

endfunction


"""sqlite_query
function! base#sqlite#query (...)
	call base#init#sqlite()

	let q_last = base#varget('base_sqlite_last_sql_query','')
	let q      = get(a:000,0,'')

	if !strlen(q)
		let q =input('SQLITE query:','','custom,base#complete#sqlite_sql')
	endif

	let lim = input('LIMIT: ','10')
	if strlen(lim)
		let q .= ' LIMIT ' . lim
	endif

	call base#varset('base_sqlite_last_sql_query',q)

	let opt_print = input('Print:','perldumper','custom,base#complete#sqlite_sql_opt_print')

	let ref = { 'opt_print' : opt_print } 
	if opt_print == 'perlpack'

		let fmt = base#varget('base_sqlite_last_pack_fmt','A30')
		let fmt = input('pack() fmt:',fmt)
	
		call base#varset('base_sqlite_last_pack_fmt',fmt)
		call extend(ref,{ 'pack_fmt' : fmt })
	endif

	let fetch = input('Fetch:','fetchrow_hashref','custom,perlmy#complete#dbi_fetch_methods')
	if !len(fetch)
		let fetch=base#getfromchoosedialog({ 
			\ 'list'        : base#varget('perlmy_dbi_fetch_methods',[]),
			\ 'startopt'    : 'fetchrow_hashref',
			\ 'header'      : "Available fetch methods are: ",
			\ 'numcols'     : 1,
			\ 'bottom'      : "Choose fetch by number: ",
			\ })
	endif

	call extend(ref,{ 
		\	'fetch'  : fetch,
		\	'dbtype' : 'sqlite',
		\	})

	let lines = base#sql#q(q,ref)
	call base#buf#open_split({ 'lines' : lines })
	return 1

endfunction

"""sqlite_table_describe
function! base#sqlite#table_describe ()
	call base#init#sqlite()

	let ref = {
			\	'fetch'     : 'fetchrow_arrayref',
			\	'opt_print' : 'perlpack',
			\	'dbtype'    : 'sqlite',
			\	}
	let table = input('table:','','custom,base#complete#sqlite_tables')
	let q 		= "select * from sqlite_master where type='table' and name='".table."'"
	let lines = base#sql#q(q,ref)

	call base#buf#open_split({ 'lines' : lines })


endfunction

function! base#sqlite#info_dbfile ()
	call base#init#sqlite()

	let info=[]
perl << eof
	use File::stat;

	my $info=[];
	my $dbfile = $plgbase->dbfile || '';

	push @$info,
		'DBFILE PATH:', ( map { "\t" . $_ } ( $dbfile ) ),
		'DBFILE EXISTS:', "\t" . ((-e $dbfile) ? 'YES' : 'NO' ),
		'SIZE:'   ,(map { "\t" . $_ } ( $plgbase->db_dbfile_size || 0));

	VimListExtend('info',$info);
eof
	return info

endfunction


function! base#sqlite#info_commands ()
	call base#init#sqlite()

	let info=[]
perl << eof
	my $info=[];

	push @$info,
		'COMMANDS: ', 
		map { "\t" . $_ } ( 'BaseAct sqlite_*' );

	VimListExtend('info',$info);
eof
	return info

endfunction

function! base#sqlite#info_tables ()
	call base#init#sqlite()

	let tables = base#sqlite#tables()
	let info = []

	call add(info,'TABLES: ')
	call map(tables,'substitute(v:val,"^","\t","g")')
	call extend(info,tables)

	return info

endfunction

function! base#sqlite#tables ()
	call base#init#sqlite()

	let tables=[]
perl << eof
	use File::stat;

	my $tables=[];

	my $dbh = $plgbase->dbh;

	push @$tables,
		$plgbase->db_tables;

	VimListExtend('tables',$tables);
eof
	return tables

endfunction

function! base#sqlite#dbfiles ()
	call base#init#sqlite()

	let dbfiles = {}
perl << eof
	my $dbfiles = $plgbase->dbfiles;
	foreach my $x (keys %$dbfiles) {
		my $v = $dbfiles->{$x};
		VimLet('x',$x);
		VimLet('v',$v);
		VimCmd("call extend(dbfiles,{ x : v })");
	}
eof
	return dbfiles

endfunction

function! base#sqlite#drop_tables ()
	call base#init#sqlite()

perl << eof
	$plgbase->db_drop_tables({ all => 1 });
eof
	
endfunction

function! base#sqlite#reset_tables ()
	call base#init#sqlite()

perl << eof
	$plgbase
		->db_drop_tables({ all => 1 })
		->db_create_tables;
eof
	
endfunction

function! base#sqlite#reload_from_fs ()
	call base#init#sqlite()

perl << eof
	$plgbase->reload_from_fs;
eof
	
endfunction
