
"echo base#html#tag('th')
"echo base#html#tag('th','Row')
"echo base#html#tag('th','Row',{2:2})

function! base#html#tag (...)
	let tag = get(a:000,0,'')
	let txt = get(a:000,1,'')
	let attr = get(a:000,2,{})

	let op = '<'.tag

	for [k,v] in items(attr)
			let op = op . ' '. '"'.k.'"='.'"'.v.'"'
	endfor
	let op = op . '>'

	let cl = '</'.tag.'>'
	let s = op.txt.cl

	return s
	
endfunction

function! base#html#css_pretty(string)
	if !has('perl')
		return
	endif
	let css_pp=[]

perl << eof
	use utf8;

	use Vim::Perl qw(:funcs :vars);
	use CSS;

	my $str=VimVar('a:string');
	my $css=CSS->new({ 'adaptor' => 'CSS::Adaptor::Pretty' });

	$css->read_string($str);

	my $o = $css->output();
	my @o = split("\n",$o);
	for(@o){
		s/"/\\"/g;
		$cmd = 'call add(css_pp,"'.$_.'")';
		#VimMsg($cmd);
		VimCmd($cmd);
	}

eof
	return css_pp

endfunction

function! base#html#pretty_libxml(string)
	
	if !has('perl')
		return
	endif
	let html_pp=[]

perl << eof
	use utf8;

	use Vim::Perl qw(:funcs :vars);
	use XML::LibXML;
	use XML::LibXML::PrettyPrint;

	my $html=VimVar('a:string');

	my $doc = XML::LibXML->load_html(
			string          => $html,
			recover         => 1,
			suppress_errors => 1,
		);
	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
 	$pp->pretty_print($doc);
	my $html_pp=$doc->toString;
	my @pp=split("\n",$html_pp);

	for(@pp){
		s/"/\\"/g;
		$cmd = 'call add(html_pp,"'.$_.'")';
		#VimMsg($cmd);
		VimCmd($cmd);
	}


eof

	return html_pp

endfunction
