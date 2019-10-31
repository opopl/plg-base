
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

	my $pat = qr/^\s*([^!\t]+)\t+([^\t]+)\t+(.*)/;

	for my $tfile (@$tfiles){
		my @lines = read_file($tfile);
		my @new;
		for (@lines){
			chomp;
			#next if /^\s*!/;

			my ($tag, $file, $rest ) = ( /$pat/g );

			if ($file =~ /^[\\\/]/) {
				$file =~ s/^/c\:/g;

				s/$pat/$tag\t$file\t$rest/g;
			}

			push @new, $_;
		}
		write_file($tfile, join("\n",@new) . "\n");
	}
eof
		endif
	
endfunction
