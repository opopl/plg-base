""
"http://vim.wikia.com/wiki/Pretty-formatting_XML
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

		my $warn=sub{ 
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
