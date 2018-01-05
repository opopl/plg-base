
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

"call base#html#get_url(url,ref)
"call base#html#get_url(url,{ 'open_split' : 1 })
"call base#html#get_url(url,{ 'lynx_to_txt' : 1 })
"echo base#html#get_url(url,{ 'xpath' : '//div' })
"
" used in IdePhP url_load
"

function! base#html#get_url(url,...)
	if !has('perl') | return | endif

	let lines  = []
	let errors = []

	let ref   = get(a:000,0,{
			\	'open_split'  : 0,
			\	'check_saved' : 0,
			\	'save'        : '',
			\	})

	let xpath = get(ref,'xpath','')
	let nodes = []

	let save        = get(ref,'save')
	let check_saved = get(ref,'check_saved')

	if check_saved && strlen(save)
		let f = base#qw#catpath('saved_html',save)
		if filereadable(f)
			let lines=readfile(f)
			if strlen(xpath)
				let lines = base#html#xpath({
						\	'xpath'     : xpath,
						\	'htmllines' : lines,
						\	})
			endif
			return lines
		endif
	endif

perl << eof
	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	my $url   = VimVar('a:url');
	my $xpath = VimVar('xpath');
	
	my $htw=HTML::Work->new();
	$htw->load_html_from_url({ 
			url   => $url,
	});

	my @lines=$htw->html2lines({ xpath => $xpath });
	VimListExtend('lines',\@lines);

eof

	if get(ref,'open_split')
		call base#buf#open_split({ 'lines' : lines })
	endif

	let save = get(ref,'save','')
	if strlen(save)
		let f = base#qw#catpath('saved_html',save)
		call writefile(lines,f)
		call base#log('URL saved to: '.f)
	endif

	if get(ref,'lynx_to_txt')
	endif

	return lines

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

function! base#html#remove_a(...)
	if !has('perl') | return | endif

	let ref       = get(a:000,0,{})

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])

	if len(htmllines)
		let htmltext=join(htmllines,"\n")
	endif

	let lines = []

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use HTML::Strip;

	my $html  = VimVar('htmltext');

  my $hs = HTML::Strip->new(
			striptags   => [ qw(aa htm) ],
			#emit_spaces => 0,
	);

  my $html_strip = $hs->parse( $html );
  $hs->eof;

	VimMsg($html_strip);

	my @lines=split("\n",$html_strip);
	VimListExtend('lines',\@lines);

eof
	return lines

endfunction

function! base#html#remove_a_libxml(...)
	if !has('perl') | return | endif

	let ref       = get(a:000,0,{})

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])

	if len(htmllines)
		let htmltext=join(htmllines,"\n")
	endif

	let lines = []

perl << eof

	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	my $html  = VimVar('htmltext');

	my $htw=HTML::Work->new(
		html    => $html,
		sub_log => sub { VimMsg($_) for(@_); },
	);
	$htw->replace_a;

	my @lines   = $htw->html2lines;

	VimListExtend(lines,\@lines);

eof
	return lines

endfunction

function! base#html#xpath(...)
	if !has('perl') | return | endif

	let ref      = get(a:000,0,{})

	let htmltext  = get(ref,'htmltext','')
	let htmllines = get(ref,'htmllines',[])
	let xpath     = get(ref,'xpath','')

	if len(htmllines)
		 let htmltext=join(htmllines,"\n")
	endif

	let filtered=split(htmltext,"\n")
	let filtered=[]
	if !strlen(xpath)
		echohl WarningMsg
		echo 'Empty XPATH'
		echohl None
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

	my $html  = VimVar('htmltext');
	my $xpath = VimVar('xpath');

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

function! base#html#list_to_txt(html)
	if !has('perl')
		return
	endif
	let lines=[]

perl << eof
	use utf8;
	use Encode;

	use Vim::Perl qw(:funcs :vars);
	use XML::LibXML;

	my $html=VimVar('a:html');

	my $doc = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);
	my $xpath='//[ul|ol]/li'

	my @nodes=$dom->findnodes($xpath);
eof
 " my @filtered;

	"for(@nodes){
		"push @filtered,split("\n",$_->toString);
	"}

	"VimListExtend('filtered',\@filtered);

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
