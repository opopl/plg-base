
function! base#json#encode (...)
	if !has('perl') | return | endif

	let jsonlist = []
	let var      = get(a:000,0,'')

perl << eof
	use JSON::XS;
	use Data::Dumper;

	use Vim::Perl qw(
		VimVar
		VimListExtend
	);

	my $var = VimVar('var');

	VIM::Msg(Dumper($var));
	my $js  = JSON::XS->new->ascii->pretty->allow_nonref;

	my $json = $js->encode($var);
	my @json = split("\n",$json);

	VimListExtend('jsonlist',\@json);

eof

	let json = join(jsonlist,"\n")
	return json
	
endfunction
