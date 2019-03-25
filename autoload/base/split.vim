
function! base#split#regex_perl (...)
	let regex	= input('regex: ','')

	let matched = []
perl << eof
	use Vim::Perl qw( VimVar VimListExtend );
	$Vim::Perl::CURBUF = $curbuf;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	my $re    = VimVar('regex');
	my $re_qr = qr/$re/;

	my @matched;
	foreach(@$lines) {
		/$re_qr/ && do {
			push @matched, $_;
		};
	}
	VimListExtend('matched',[@matched]);
eof
	call base#buf#open_split({ 'lines' : matched })
	
endfunction
