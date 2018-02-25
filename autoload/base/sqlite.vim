
function! base#sqlite#list_plugins ()
	call base#init#sqlite()

	let p=[]
perl << eof
	my @p = $plgbase->plugins;
	VimListExtend('p',\@p);
eof
	call base#buf#open_split({ 'lines' : p })
	
endfunction

function! base#sqlite#list_datfiles ()
	call base#init#sqlite()

perl << eof
	my $df = $plgbase->datfiles_ref;
	VimMsg(Dumper($df));
eof
	
endfunction

function! base#sqlite#info ()
	call base#init#sqlite()

	let info=[]
perl << eof
	use File::stat;
	my $info=[];

	push @$info,'DBFILE: '.( $plgbase->dbfile || '');
#	push @$info,'aa ';

	VimListExtend('info',$info);
eof
	call base#buf#open_split({ 'lines' : info })
	return 1

endfunction

function! base#sqlite#list_keys_datfiles ()
	call base#init#sqlite()

perl << eof
	my $df = [ $plgbase->datfiles_keys ];
	VimMsg(Dumper($df));
eof
	
endfunction



function! base#sqlite#reload_from_fs ()
	call base#init#sqlite()

perl << eof
	$plgbase->reload_from_fs;
eof
	
endfunction
