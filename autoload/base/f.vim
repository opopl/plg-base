
"let ref = {
	"\	'fileid': <++> ,
	"\	'file'  : <++>,
	"\	'type'  : <++>,
	"\	}
"call base#f#add(ref)


function! base#f#add (...)
	let ref=get(a:000,0,{})

  if ! exists("s:files") | let s:files={} | endif

	let fileid = get(ref,'fileid','')
	let file   = get(ref,'file','')
	let type   = get(ref,'type','')

	let ex = { 'fileid' : { 'file' : file, 'type' : type } }
	call extend(s:files,ex) 

	call base#init#sqlite()
perl << eof
	use Vim::Perl qw(:funcs :vars);

	my ($dbh,$sth);

	my $fileid = VimVar('fileid');
	my $type   = VimVar('type');
	my $file   = VimVar('file');

	$plgbase->db_create_tables;
	$dbh = $plgbase->dbh;

	my $q=qq{
		insert into files(fileid,type,file) values(?,?,?);
	};
	eval { $sth = $dbh->prepare($q); };
	if ($@) { $plgbase->warn($@); return; }

	$sth->execute($fileid,$type,$file);
eof
	
endfunction
