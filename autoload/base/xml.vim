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
		use Vim::Perl qw(:funcs :vars);
		use Base::XML qw($DOMCACHE $XPATHCACHE $DOM);
		#use Vim::Plg::idephp qw($doms_xml);

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

		#VimMsg($dom->toString);
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


function! base#xml#xpath_attr (...)
		let xpath     = get(a:000,0,'')
		let attr_list = get(a:000,1,[])

		let attr_val=[]

perl << eof
		my $dom  = $Base::XML::DOM;
		my $xpc  = $Base::XML::XPATHCACHE;

		my $xpath     = VimVar('xpath') || '';

		my $attr_list = VimVar('attr_list') || [];
		my $attr_val  = [];

		my $nodes     = $xpc->{$xpath} || [ $dom->findnodes($xpath) ];
		foreach my $attr_name (@$attr_list) {
			foreach my $n (@$nodes) {
				my $attr = $n->getAttribute($attr_name);

				my $val = ((defined $attr) ? $attr : '');

				push @$attr_val, $val;
			}
		}
		VimListExtend('attr_val',$attr_val);
eof
		return attr_val

endfunction

function! base#xml#xpath_lines (...)
		let xpath = get(a:000,0,'')

		let ref   = get(a:000,1,{})

		let list = []
perl << eof
		my $dom = $Base::XML::DOM;

		unless (defined $dom){
			VimWarn('$Base::XML::DOM undefined!');
			return;
		}

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

		my $s=sub {
			my @r;
			local $_ = shift;

			$_;
		};
		@list = map { $s->($_) } @list;
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
