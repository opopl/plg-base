
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
