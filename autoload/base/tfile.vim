
function! base#tfile#process (...)
	let ref = get(a:000,0,{})

	let tfile = get(ref,'tfile','')

	if has('win32')
perl << eof
	use File::Slurp qw(read_file);

	my $tfile = VimVar('tfile');
	my @lines = read_file($tfile);
	for my $line (@lines){
	}
eof
	endif
	
endfunction
