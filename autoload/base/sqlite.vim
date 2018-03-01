
"""sqlite_list_plugins
function! base#sqlite#list_plugins ()
	call base#init#sqlite()

	let p=[]
perl << eof
	$plgbase->get_plugins_from_db;

	my @p = $plgbase->plugins;
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
	$plgbase->get_datfiles_from_db({ 'reload_from_fs' => 1 });

	my $k = [ $plgbase->datfiles_keys ];
	VimListExtend('k',$k);
eof
	let k=sort(k)
	call base#buf#open_split({ 'lines' : k })
	
endfunction

"""sqlite_list_datfiles
function! base#sqlite#list_datfiles ()
	call base#init#sqlite()

perl << eof
	my $df = $plgbase->datfiles_ref;
	VimMsg(Dumper($df));
eof
	
endfunction

function! base#sqlite#tk ()
perl << eof
	package main;
	use base qw( use Vim::Plg::Base::Tk );
	__PACKAGE__->new( plgbase => $plgbase )->run;

eof

endfunction

function! base#sqlite#info (...)
	call base#init#sqlite()

	let ref    = get(a:000,0,{})
	let prompt = get(ref,'prompt',0)

	let info=[]

	if prompt
	else
		call extend(info,base#sqlite#info_dbfile())
		call extend(info,base#sqlite#info_tables())
	endif

	call base#buf#open_split({ 'lines' : info })
	return 1

endfunction


"""sqlite_sql
function! base#sqlite#info_sql (...)
	call base#init#sqlite()

	let q_last = base#varget('base_sqlite_last_sql_query','')
	let q      = get(a:000,0,'')

	if !strlen(q)
		let q =input('SQLITE query:','','custom,base#complete#sqlite_sql')
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

	let fetch = input('Fetch:','','custom, perlmy#complete#dbi_fetch_methods')
	if !len(fetch)
		let fetch=base#getfromchoosedialog({ 
			\ 'list'        : base#varget('perlmy_dbi_fetch_methods',[]),
			\ 'startopt'    : 'fetchrow_arrayref',
			\ 'header'      : "Available fetch methods are: ",
			\ 'numcols'     : 1,
			\ 'bottom'      : "Choose fetch by number: ",
			\ })
	endif

	call extend(ref,{ 'dbtype' : 'sqlite' })
	let lines = base#sql#q(q,ref)
	call base#buf#open_split({ 'lines' : lines })
	return 1

endfunction

function! base#sqlite#info_dbfile ()
	call base#init#sqlite()

	let info=[]
perl << eof
	use File::stat;
	my $info=[];

	push @$info,'DBFILE: '.( $plgbase->dbfile || '');
	push @$info,'SIZE:   '.( $plgbase->db_dbfile_size || 0);

	VimListExtend('info',$info);
eof
	return info

endfunction

function! base#sqlite#info_tables ()
	call base#init#sqlite()

	let info=[]
perl << eof
	use File::stat;
	my $info=[];

	my $dbh=$plgbase->dbh;

	push @$info,'TABLES: ', map { "\t".$_ } $plgbase->db_tables;

	VimListExtend('info',$info);
eof
	return info

endfunction


function! base#sqlite#drop_tables ()
	call base#init#sqlite()

perl << eof
	$plgbase->db_drop_tables({ all => 1 });
eof
	
endfunction

function! base#sqlite#reload_from_fs ()
	call base#init#sqlite()

perl << eof
	$plgbase->reload_from_fs;
eof
	
endfunction
