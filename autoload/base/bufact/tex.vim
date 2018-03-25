
function! base#bufact#tex#set_tag_file ()
	call base#buf#start()
	let proj = projs#proj#name()
	let sec = b:sec
perl << eof
	use Vim::Perl qw(:funcs :vars);
	use Data::Dumper;
	my $lines = $curbuf->Get( 1 .. $curbuf->Count );

	my $has=0;
	for(@$lines){
			/^%%file\s+/ && do { $has=1; };
	}
	if (!$has) {
		unshift @$lines,('','%%file ' . $secname,'');
	}
	CurBufSet({ curbuf => $curbuf, text => join("\n",@$lines) });
eof
endf
