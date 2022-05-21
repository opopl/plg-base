
"Purpose
"   json encode vim variables
"Usage
"   let json = base#json#encode (data)

function! base#json#encode (...)
  if !has('python3') | return | endif

  let data      = get(a:000,0,'')

python3 << eof
import json

data = vim.eval('data')

js = json.dumps(data, ensure_ascii=False)

eof

  let json = py3eval('js')
  return json
  
endfunction

function! base#json#decode (...)
  if !has('python3') | return | endif

	let ref = get(a:000,0,{})

  let file  = get(ref,'file','')
	let json = ''
	if filereadable(file)
	  let lines = readfile(file)
	  let json  = join(lines, "\n")
	endif

  let jstr = get(ref,'json',json)

python3 << eof
import json

jstr = vim.eval('jstr')

decoded = json.loads(jstr)

eof

  let decoded = py3eval('decoded')
  return decoded

endfunction

function! base#json#encode_perl (...)
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

  my $js  = JSON::XS->new->ascii->pretty->allow_nonref;

  my $json = $js->encode($var);
  my @json = split("\n",$json);
  
  VimListExtend('jsonlist', \@json, { escape => 0 });

eof

  let json = join(jsonlist,"\n")
  return json
  
endfunction
