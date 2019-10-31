
function! base#tfile#process (...)
	let ref = get(a:000,0,{})

	let tfile = get(ref,'tfile','')
	let tfiles = []

	if !strlen(tfile)
		let tfiles = tagfiles()
	else
		call add(tfiles,tfile)
	endif

		if has('win32')
perl << eof
	use Vim::Perl qw(VimVar);
	use File::Slurp qw(read_file write_file);

	my $tfiles = VimVar('tfiles');

	for my $tfile (@$tfiles){
		my @lines = read_file($tfile);
		my @new;
		for (@lines){
			chomp;
			my ($tag, $file, $address ) = ( /^(.*)\t+(.*)\t+(.*)$/g );

			print $file . "\n";
		}
	}
eof
		endif
	
endfunction
