

function! base#bufact#html#lynx_dump_split ()

	let starthead = input('Start:',0)
	let endhead   = input('End:',10)
	let sep       = input('Separator:',',')
	let prefix    = input('Prefix:','f')

perl << eof
	my $start  = VimVar('starthead');
	my $end    = VimVar('endhead');
	my $sep    = VimVar('sep');
	my $prefix = VimVar('prefix');

	my @h = map { $prefix . $_ } ($start .. $end );
	my $h = join($sep,@h);

	$curbuf->Append(0,$h);
eof
	
endfunction


