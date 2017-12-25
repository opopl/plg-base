
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

function! base#html#strip(string)
	if !has('perl')
		return
	endif

perl << eof
	use utf8;

	use Vim::Perl qw(:funcs :vars);
	use CSS;

	use HTML::Strip;

	my $hs = HTML::Strip->new();

  my $clean_text = $hs->parse( $raw_html );
  $hs->eof;

eof

endfunction

function! base#html#get_url(url,...)
	if !has('perl')
		return
	endif

	let lines  = []
	let errors = []

	let ref   = get(a:000,0,{})

	let xpath = get(ref,'xpath','')
	let nodes = []

perl << eof
	use utf8;
	use Encode;
	use URI;
	use Data::Dumper qw(Dumper);

	use Vim::Perl qw(:funcs :vars);
	use LWP;

	use XML::LibXML;
	use XML::LibXML::PrettyPrint;

	my $url   = VimVar('a:url');
	my $xpath = VimVar('xpath');

	my $uri= URI->new($url);
	my $ua = LWP::UserAgent->new;

 	my $response = $ua->get($uri);

	my ($content,$statline);
 	if ($response->is_success) {
		 $content =  $response->decoded_content;
 	} else { 
		 	$statline = $response->status_line;
 	}

	my $dom = XML::LibXML->load_html(
			string          => $content,
			recover         => 1,
			suppress_errors => 1,
	);

	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
 	$pp->pretty_print($dom);

	my $html_pp;
	$html_pp=$dom->toString;
	
	my @lines=split("\n",$html_pp);
	
	foreach my $l (@lines) {
		$l=~s/\\/\\\\/g;
		$l=~s/"/\\"/g;
		VimCmd('let line='.'"'.$l.'"');
		VimCmd('call add(lines,line)');
	}

eof
	call base#buf#open_split({ 'lines' : lines })

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

function! base#html#xpath(htmltext,xpath)
	if !has('perl')
		return
	endif

	let filtered=split(a:htmltext,"\n")
	if !strlen(a:xpath)
		return filtered
	endif

perl << eof
	# read https://habrahabr.ru/post/53578/ about encodings
	# http://www.nestor.minsk.by/sr/2008/09/sr80902.html
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use XML::LibXML;
	use XML::LibXML::PrettyPrint;

	my $html  = VimVar('a:htmltext');
	my $xpath = VimVar('a:xpath');

	my $dom = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);

	my @nodes=$dom->findnodes($xpath);
	my @filtered;

	for(@nodes){
		push @filtered,split("\n",$_->toString);
	}

	VimListExtend('filtered',\@filtered);
eof

	return filtered

endfunction

function! base#html#pretty_libxml(string)
	
	if !has('perl')
		return
	endif
	let html_pp=[]

perl << eof
	# read https://habrahabr.ru/post/53578/ about encodings
	# http://www.nestor.minsk.by/sr/2008/09/sr80902.html
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use XML::LibXML;
	use XML::LibXML::PrettyPrint;

	my $html=VimVar('a:string');

	my $doc = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);

	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
 	$pp->pretty_print($doc);

	my $html_pp;
	
	$html_pp=$doc->toString; 

	my @pp;

	push @pp,split("\n",$html_pp);
	for(@pp){
		s/\\/\\\\/g;
		s/"/\\"/g;
		$cmd = 'call add(html_pp,"'.$_.'")';
		VimCmd($cmd);
	}

eof

	return html_pp

endfunction
