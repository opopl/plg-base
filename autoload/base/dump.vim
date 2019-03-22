
function! base#dump#dict_tabbed (dict)
	let dict = a:dict
	let data = []
	let headers = base#qw('key value')

	for [k,v] in items(dict)
		call add(data,[k,v])
	endfor

	let tabbed = pymy#data#tabulate({ 
		\	'data'    : data,
		\	'headers' : headers })
	return tabbed


	
endfunction

function! base#dump#yaml (thing)
	let thing = a:thing
perl << eof
	use YAML::XS;
	use JSON::XS;
	use Vim::Perl qw(VimVar VimLet);
	
	my $thing = VimVar('thing');
	my $yaml = Dump $thing;
	my @yaml = split "\n",$yaml;
	
	VimLet('y',\@yaml);
	#VimCmd(qq| call base#buf#open_split({ 'text' : y }) |);
	VimCmd(qq| return y |);

eof

endfunction
