
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
			\	'actions'     : [],
			\	})

	let xpath   = get(ref,'xpath','')
	let actions = get(ref,'actions',[])

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

	if strlen(save)
		let savedfile = base#qw#catpath('saved_html',save)
	endif

perl << eof
	use Vim::Perl qw(:funcs :vars);
	use HTML::Work;

	my $url   = VimVar('a:url');
	my $xpath = VimVar('xpath');
	my @actions = VimVar('actions');
	
	my $htw=HTML::Work->new(
		sub_log => sub { VimMsg($_) for(@_);}
	);
	$htw->load_html_from_url({ 
			url   => $url,
	});

	for(@actions){
		/^replace_a/ && do {
			$htw->replace_a;
		};
	}

	my @lines=$htw->htmllines({ xpath => $xpath });
	VimListExtend('lines',\@lines);

	my $save      = VimVar('save');
	my $savedfile = VimVar('savedfile');

	if($save){
		$htw->html_saveas({ 
			xpath => $xpath, 
			file  => $savedfile,
		});
	}

eof
	if get(ref,'open_split')
		call base#buf#open_split({ 'lines' : lines })
	endif

	for action in actions
		if action == 'lynx_to_txt'
			echo action
			let tmp=tempname()
			call writefile(lines,tmp)
			let cmd = 'lynx -dump -force_html '.tmp
			let ok = base#sys({ "cmds" : [cmd]})
			let lines = base#varget('sysout',[])
		endif
	endfor

	if get(ref,'lynx_to_txt')
	endif

	return lines

endfunction

function! base#html#headings (...)
	let ref   = get(a:000,0,{})

	let lines = get(ref,'lines',[])
	let file  = get(ref,'file','')

	if filereadable(file)
		 let lines=readfile(file)
	endif

	let headnums = base#listnewinc(1,5,1)
	let heads    = map(headnums,'"self::h".string(v:val)')
	let he       = join(heads,' or ')
	let h        = []

	let xp    = base#html#xpath({
			\	'xpath'     : '//*['.he.']',
			\	'htmllines' : lines,
			\	})

	call map(xp,'xolox#misc#str#trim(v:val)')

	call extend(h,xp)
	return h
	
endfunction

function! base#html#text_between_headings (...)
	let ref   = get(a:000,0,{})
	let lines = get(ref,'lines',[])

	let text = []
	let h    = base#html#headings(ref)

	return text

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

	VimListExtend('css_pp',[@o]);

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
	use HTML::Work;

	my $html  = VimVar('htmltext');
	
	my $htw=HTML::Work->new(
		html => $html,
	);
	$htw->replace_a;
	my $lines = $htw->htmllines;

	VimListExtend('lines',$lines);

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

	my @lines   = $htw->htmllines;

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

	my ($dom,@nodes,@filtered);

	$dom = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);

	@nodes=$dom->findnodes($xpath);
	@filtered;

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
	
	if !has('perl') | return [] | endif
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

	my $doc;

	eval { $doc = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);};
	if($@){ VimWarn($@); }

	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
 	$pp->pretty_print($doc);

	my $html_pp;
	$html_pp=$doc->toString; 

	my @pp;

	push @pp,(split("\n",$html_pp));
	VimListExtend('html_pp',\@pp);

eof

	return html_pp

endfunction
