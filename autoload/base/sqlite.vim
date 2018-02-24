
function! base#sqlite#list_plugins ()
	call base#init#sqlite()

perl << eof
	my @p = $plgbase->plugins;

	VimMsg(Dumper(\@p));
	VimMsg(Dumper($plgbase->datfiles_ref));
	VimMsg(Dumper($plgbase->plugins_ref));

eof
	
endfunction

function! base#sqlite#reload_from_fs ()
	call base#init#sqlite()

perl << eof
	$plgbase->reload_from_fs;
eof
	
endfunction
