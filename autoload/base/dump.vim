
function! base#dump#py (thing)
python << eof
import vim
thing = vim.eval('a:thing')
eof
	
endfunction

function! base#dump#yaml (thing)
	let thing = a:thing
	let dmp = base#pp#pp(thing)
	echo dmp
perl << eof
use YAML::XS;
use JSON::XS;
use String::Escape qw(escape);

my $coder = JSON::XS->new->ascii->pretty->allow_nonref;

my $dmp = VimVar('dmp');
print $dmp;
my $p = $coder->decode($dmp);
print Dumper($p);
eof
	return dmp

endfunction
