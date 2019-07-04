
"""xpath
function! base#bufact#xml#xpath ()
	call base#buf#start()

  call base#bufact#html#xpath ()
endf

"""remove_xpath
function! base#bufact#xml#remove_xpath ()
	call base#buf#start()

  call base#bufact#html#remove_xpath ()
endf

" rename attributes
"
function! base#bufact#xml#a_rename ()
	call base#html#htw_load_buf()

	let xpath = '//*' 
	let xpath = base#input_we('xpath:', xpath)

	let msg_a = [
			\	'old, new; old1, new1; '
			\	,' attributes to be renamed:'
			\	]
	let msg = join(msg_a, "\n")

	"attributes to be renamed
	let attr_rn   = {}

	let attr_s = base#input_we(msg, '')
	let pairs  = base#map#trim( split(attr_s,";") )

	for pair in pairs
		let pair_a = split(pair,",")
		let old = get(pair_a,0,'')
		let new = get(pair_a,1,'')
		call extend(attr,{ old : new })
	endfor
perl << eof
	use Vim::Perl qw(:funcs :vars);

	my $xpath    = VimVar('xpath') || '//*';
	my $attr_rn  = VimVar('attr_rn') || {};

	my $xml = $HTW
		->attr_rename({ 
				xpath => $xpath,
				attr  => $attr_rn
		})
		->htmlstr;

	CurBufSet({ 
		text   => $xml, 
		curbuf => $curbuf 
	});
eof

endf

" delete attributes

function! base#bufact#xml#a_delete ()
	call base#html#htw_load_buf()

	let xpath = '//*' 
	let xpath = base#input_we('xpath:',xpath)

	let attr_s = ''
	let attr_s = input('comma-separated list of attributes: ',attr_s)

	let attr = split(attr_s, ",")

perl << eof
	use Vim::Perl qw(:funcs :vars);

	my $xpath = VimVar('xpath') || '//*';
	my $attr  = VimVar('attr') || [];

	my $xml = $HTW
		->attr_remove({ 
				xpath => $xpath,
				attr  => $attr
		})
		->htmlstr;

	CurBufSet({ 
		text   => $xml, 
		curbuf => $curbuf 
	});
eof

endfunction

"""quickfix_xpath
function! base#bufact#xml#quickfix_xpath ()
	call base#buf#start()

  call base#bufact#html#quickfix_xpath ()

endf

"""pretty_perl_libxml

function! base#bufact#xml#pretty_perl_libxml ()
	call base#buf#start()

  call base#bufact#html#pretty_perl_libxml ()

endf
