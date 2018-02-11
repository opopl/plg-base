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

		my $warn=sub{ 
			VIM::Msg($_,"WarningMsg") for(@_);
		};

		my @mods=qw(
			XML::LibXML::PrettyPrint
		);
		foreach my $mod (@mods) {
			eval { require $mod; $mod->import; };
			if (@$) { 
				$warn->('Failure: use '.$mod,$@); 
			}
		}
		use String::Escape qw(quote);

		my ($doc, $pp, $xml_origin, $xml_pretty);
		
		$xml_origin = VIM::Eval('xml_origin');

		eval {
			$doc = XML::LibXML->new(
				xml => $xml_origin,
			);
		};

		if ($@) { $warn->( '[XML::LibXML] new() failure:',$@); }
		if (! defined $doc) {
				$warn->( '[XML::LibXML] $doc UNDEFINED' );
		}
		
		$pp  = XML::LibXML::PrettyPrint->new;
		eval { $xml_pretty = $pp->pretty_print($doc)->toString; };
		if ($@) { $warn->('[XML::LibXML::PrettyPrint] pretty_print() failure:',$@); }

		VIM::DoCommand('let xml_pretty='.quote($str));

eof
		split
		enew
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
