
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
	let html = join(lines,"\n")

	let headnums = base#listnewinc(1,5,1)
	let heads    = map(headnums,'"self::h".string(v:val)')
	let he       = join(heads,' or ')
	let h        = []

	let xpath = '//*['.he.']'

perl << eof
	use Vim::Xml qw($PARSER $PARSER_OPTS);
	use XML::LibXML;
	use XML::LibXML::PrettyPrint;
	use Encode qw(decode);
	my ($dom,@nodes,$parser);

	$parser=$PARSER || XML::LibXML->new; 

	#	my $xpath    = VimVar('xpath');
	my $html=VimVar('html');

	my @headnums = (1 .. 5);
	my @heads    = map { "self::h" . $_ } @headnums;
	my $he       = join(' or ',@heads);
	my $xpath    = '//*['.$he.']';

#"//*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5]
#//*[preceding-sibling::h2 = 'Summary' and following-sibling::h2 = 'Location']

	my $xml_libxml_parser_options=$PARSER_OPTS || 
	{
			expand_entities => 0,
			load_ext_dtd 		=> 1,
			keep_blanks     => 1,
			no_cdata        => 0,
			line_numbers    => 1,
	};

	$parser->set_options(%$xml_libxml_parser_options);

	my $inp={
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	};

	$dom = $parser->load_html(%$inp);

	my $nodelist = $dom->findnodes($xpath);
	my $sub      = sub { local $_=shift; s/^h(\d+)/$1/g; $_ };
	my @children;
	my @sn;

	my $pp     = XML::LibXML::PrettyPrint->new(indent_string => " ");
	#my $newdom = XML::LibXML::Document->new;

	my %added=();
	my @nodes;
	while(my $node = $nodelist->pop) {
		 unshift @nodes,$node;
		 my $lnum=$node->line_number;
 		 $pp->pretty_print($node);

		 my $pos = $nodelist->size;
		 my $cmt = "*" x 10 . "pos: ".$pos;
		 my $cn  = XML::LibXML::Comment->new($cmt);

		 $node->setAttribute('node_lineno',$lnum);
		 $node->setAttribute('node_id',$pos);

		 my $text=$node->textContent;
		 $text=~s/^\s*//g;
		 $text=~s/\s*$//g;
		 $node->setAttribute('node_text',$text);
		 my @textchildren;
		 
		 for($node->childNodes() ){
				if ($_->nodeType == XML_TEXT_NODE) {
					push @textchildren,$_;
				}
		 }
		 for my $tchild (@textchildren){
		 		$node->removeChild($tchild);
		 }

		 my $prev = $nodelist->get_node($pos);
		 last unless $prev;

		 my $n_prev = $sub->($prev->nodeName);
		 my $n_node = $sub->($node->nodeName);
		 my %n=(
			 	prev => $n_prev,
			 	node => $n_node,
		 );
		 #VimMsg(Dumper(\%n));

		 if ($n_node eq '1') {
				#VimMsg($node->toString);
		 }
		 if ($n_prev eq '1') {
				#VimMsg($prev->toString);
		 }

		 unshift @children,{ 
		 		node => $node,
				num  => $n_node,
				line => $node->line_number,
		 };
		 
		 if ($n{prev} < $n{node}) {
				for my $c (@children){
					my $child      = $c->{node};
					my $child_num  = $c->{num};
					my $child_line = $c->{line};

					my $clone=$child->cloneNode(1);

					next if ($n{prev} > $child_num);

					$prev->addChild($child);
					$added{$child_line}=1;
				}
				@children=();
		 }else{
		 }
	}

	my @n = map { $added{$_->line_number} ? $_ : () } @nodes;
	my @s = map { $pp->pretty_print($_); $_->toString } @n;

	my $stars = '*' x 50;
	VimMsg([$stars,'Added nodes',$stars]);
	for(@s){
		VimMsg('-'x 50);
		VimMsg($_);
	}
	
eof

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

	let add_comments = get(ref,'add_comments',0)
	let cdata2text   = get(ref,'cdata2text',0)
	let load_as      = get(ref,'load_as','html')

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

	use Vim::Xml qw(%nodetypes node_cdata2text $DOM $PARSER $PARSER_OPTS);

	my $html         = VimVar('htmltext');
	my $xpath        = VimVar('xpath');
	my $ref          = VimVar('ref') || {};

	my $add_comments = VimVar('add_comments');
	my $cdata2text   = VimVar('cdata2text');
	my $load_as      = VimVar('load_as');

	my ($dom,@nodes,@filtered,$parser);

	$parser=$PARSER || XML::LibXML->new; 

	my $xml_libxml_parser_options=$PARSER_OPTS || 
	{
			expand_entities => 0,
			load_ext_dtd 		=> 1,
			keep_blanks     => 1,
			no_cdata        => 0,
	};

	$parser->set_options(%$xml_libxml_parser_options);

	my $inp={
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	};

	if ($load_as eq 'xml') {
		$dom = $parser->load_xml(%$inp);
	} elsif ($load_as eq 'html'){
		$dom = $parser->load_html(%$inp);
	}

	@nodes=$dom->findnodes($xpath);
	@filtered;

	for my $node (@nodes){
		my $ntype=$node->nodeType;
		if ($add_comments) {
			my $cmts = [
				'nodeType='.$nodetypes{$ntype} || 'undef',
			];
			foreach my $cmt (@$cmts) {
				my $cnode=XML::LibXML::Comment->new($cmt);
				push @filtered,$cnode->toString;
			}
		}

		if ($cdata2text) {
			$node = node_cdata2text($node,$dom,$parser);
		}
		push @filtered,split("\n",$node->toString);
	}

	VimListExtend('filtered',\@filtered);
eof

	return filtered

endfunction

function! base#html#xpath_lineno(...)
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

	for my $node (@nodes){
		VimLet('string',$node->toString);
		VimLet('lnum',$node->line_number);
		VimLet('text',$node->textContent || '');
		my $cmd = 'call add(filtered,' ;
		$cmd .='{ "lnum"   : lnum, '   ;
		$cmd .='  "text"   : text,'    ;
		$cmd .='  "string" : string,'  ;
		$cmd .='})'                    ;
		VimCmd($cmd);
	}

eof

	return filtered

endfunction

function! base#html#xpath_remove_nodes(...)
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

	my $ref = VimVar('ref') || {};

	my ($dom,@nodes,@filtered);

	$dom = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);

	@nodes=$dom->findnodes($xpath);
	unless(@nodes){ return; }

	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
	for my $node (@nodes){
		my $parent=$node->parentNode;
		eval { $parent->removeChild($node); };
		if ($@) {
			VimWarn($@);
			next;
		}
 		$pp->pretty_print($parent);
	}
	$html=$dom->toString;

	if ($ref->{fillbuf}) {
		my $c=$curbuf->Count(); 
		VimMsg($c);
		$curbuf->Delete(1,$c);
		$curbuf->Append(1,split("\n",$html));
	}
	VimLet('htmltext',html);
	return $html;
eof

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
