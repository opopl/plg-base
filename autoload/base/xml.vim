""
"http://vim.wikia.com/wiki/Pretty-formatting_XML
"
"

function! base#xml#load_from_file(file,...)
		let file = a:file
		let opts = get(a:000,0,{})

		let reload = get(opts,'reload',1)

perl << eof
		use strict;
		use warnings;

		use XML::LibXML;
		use Vim::Perl qw(VimVar VimWarn);
		use Base::XML qw($DOMCACHE $DOM);

		use String::Escape qw(quote);

		my $file   = VimVar('file');
		my $reload = VimVar('reload');

		if(! -e $file ){VimWarn('File does not exist:', $file); return; }

		my ( $fh, $dom );

		eval {
				open $fh, '<', $file;
				binmode $fh; 
		};
		if($@){
			VimWarn('Errors while loading file: ',$file,$@);
			return;
		}

		$dom = $DOMCACHE->{$file};

		if( $reload || not defined $dom){
			eval { $dom = XML::LibXML->load_xml(IO => $fh); };
			if($@){
				VimWarn('Errors while XML::LibXML->load_xml(IO => $fh): ',$@);
				close $fh;
				return;
			}
			$DOMCACHE->{$file} = $dom;
		}

		unless( defined $dom ){ VimWarn('DOM is not defined!'); return; }
		$DOM = $dom;

		close $fh;
eof
	
endfunction

function! base#xml#load_from_string(string,...)
		let string = a:string
		let opts   = get(a:000,0,{})

perl << eof
		use strict;
		use warnings;

		use XML::LibXML;
		use Vim::Perl qw(VimWarn VimVar);
		use Base::XML qw($DOMCACHE $XPATHCACHE $DOM);

		use IO::String;

		my $string = VimVar('string');

		my($fh,$dom);
		$fh=IO::String->new($string);

		eval { $dom = XML::LibXML->load_xml(IO => $fh); };
		if($@){
				VimWarn('Errors while XML::LibXML->load_xml(IO => $fh): ',$@,'$string=',$string);
				close $fh;
				return;
		}

		unless(defined $dom){ VimWarn('DOM is not defined!'); return;}
		$DOM=$dom;

		close $fh;
eof
	
endfunction

"Usage:
"	let attr_val = base#xml#xpath_attr (xpath,attr_list)
"
"Examples:
"	let [name] = base#xml#xpath_attr (xpath,[ 'name' ])

function! base#xml#xpath_attr (...)
		let xpath     = get(a:000,0,'')
		let attr_list = get(a:000,1,[])

		let attr_vals = []

perl << eof
		my $dom  = $Base::XML::DOM;
		my $xpc  = $Base::XML::XPATHCACHE;

		my $xpath     = VimVar('xpath') || '';

		my $attr_list = VimVar('attr_list') || [];
		my $attr_vals  = [];

		my $nodes     = $xpc->{$xpath} || [ $dom->findnodes($xpath) ];
		foreach my $attr_name (@$attr_list) {
			foreach my $n (@$nodes) {
				my $attr = $n->getAttribute($attr_name);

				my $val = ((defined $attr) ? $attr : '');

				push @$attr_vals, $val;
			}
		}
		VimListExtend('attr_vals',$attr_vals);
eof
		"let attr_vals = map(attr_vals,'substitute(v:val,"\\\\","\\","g")')
	
		return attr_vals

endfunction

"Usage:
"	let text = base#xml#xpath_text_split (xpath)

function! base#xml#xpath_text_split (...)
		let xpath = get(a:000, 0, '')

		let ref   = get(a:000, 1, {})

		let text_split = []
perl << eof
		use Base::String qw(str_split);

		my $dom = $Base::XML::DOM;

		unless (defined $dom){
			VimWarn('$Base::XML::DOM undefined!');
			return;
		}

		my $ref = VimVar('ref') || {};
		my @content;

		my $s = sub {
			my $n = shift;
			my $t = $n->textContent || '';
			push @content, str_split( $t );
		};
		$dom->findnodes($xpath)->map($s);
		VimLet('text_split',[@content]);
eof
		return text_split

endfunction

"Usage:
"  let lines = base#xml#xpath_lines(xpath)
"  let lines = base#xml#xpath_lines(xpath, { 'trim' : 1 })

function! base#xml#xpath_lines (...)
		let xpath = get(a:000,0,'')

		let ref   = get(a:000,1,{})

		let list = []
perl << eof
		use String::Util qw(trim);

		my $dom = $Base::XML::DOM;

		unless (defined $dom){
			VimWarn('$Base::XML::DOM undefined!');
			return;
		}

		my $ref = VimVar('ref') || {};

		my $xpath = VimVar('xpath');
		unless ($xpath){
			VimWarn('empty xpath!');
			return;
		}
		
		my @n     = $dom->findnodes($xpath);

		my $n = sub { 
			local $_ = shift;
			my $t = $_->toString;
			my @t = split("\n",$t);
			@t;
		};
		my @list = map { $n->($_) } @n;

		if ($ref->{trim}) {
			@list = map { trim($_) } @list;
		}
		@list = grep { ($_) ? 1 : 0 } @list;
		VimListExtend('list',[@list]);
	
eof
		return list
	
endfunction

function! base#xml#pretty()
	if base#noperl() 
		call base#xml#pretty_xmllint()
		return
	else

		let xml_pretty = ''
		let xml_origin = join(getline(1,'$'),"\n")

perl << eof
		use XML::LibXML::PrettyPrint;
		use XML::LibXML;
		use Vim::Perl qw(:funcs :vars);

		use strict;
		use warnings;

		use String::Escape qw(quote);

		my $warn = sub { 
			VIM::Msg($_,"WarningMsg") for(@_);
		};

		my ($doc, $pp, $xml_origin, $xml_pretty);
		
		$xml_origin = VIM::Eval('xml_origin');

		eval {
			$doc = XML::LibXML->load_xml(
				string => $xml_origin,
			);
		};

		if ($@) { $warn->( '[XML::LibXML] new() failure:',$@); }
		if (! defined $doc) {
				$warn->( '[XML::LibXML] $doc UNDEFINED' );
				return;
		}
		
		$pp  = XML::LibXML::PrettyPrint->new(indent_string => " " );
		eval { 
			$pp->pretty_print($doc); 
			$xml_pretty = $doc->toString; 
		};
		if ($@) { $warn->('[XML::LibXML::PrettyPrint] pretty_print() failure:',$@); }

		$xml_pretty=~s/"/\\"/g;
		$xml_pretty=~s/'/\\'/g;
		VIM::DoCommand('let xml_pretty='.'"'.$xml_pretty.'"');
		#VimMsg($xml);

eof
		call base#buf#open_split({ 'lines' : split(xml_pretty,"\n") })
		"split
		"enew
	endif
endfunction

function! base#xml#pretty_xmllint()

	" save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format --pretty 2 -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft

endfunction

function! base#xml#encode (...)
	let var = get(a:000,0,'')
	if !has('perl') 
		return
	endif
	
endfunction

function! base#xml#a_rename_input (...)

	let xpath = '//*' 
	let xpath = base#input_we('xpath:', xpath)

	let msg_a = [
			\	'old, new; old1, new1; '
			\	,' attributes to be renamed:'
			\	]
	let msg = join(msg_a, "\n")

	"attributes to be renamed
	let attr_rn   = {}

	let xx = base#varget('xml_rename_attr',[])
	let last = get(xx,-1,'')

	call base#varset('this',xx)
	let cmpl = 'custom,base#complete#this'

	let attr_s = base#input_we(msg, last,{ 'complete' : cmpl })

	call add(xx, attr_s)
	call base#varset('xml_rename_attr',xx)

	call base#varset('this','attr_s')

	let pairs  = base#map#trim( split(attr_s,";") )

	for pair in pairs
		let pair_a = split(pair,",")
		let old = get(pair_a,0,'')
		let new = get(pair_a,1,'')
		call extend(attr_rn,{ old : new })
	endfor

	return [ xpath, attr_rn ] 

endfunction
