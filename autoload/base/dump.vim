
function! base#dump#py (thing)
python << eof
import vim
thing = vim.eval('a:thing')
eof
	
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
