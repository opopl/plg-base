
"""xpath
function! base#bufact#tml#xpath ()
  call base#buf#start()

  call base#bufact#html#xpath ()
endf

function! base#bufact#tml#w_xpath ()
  call base#buf#start()

  call base#bufact#html#w_xpath ()
endf

"""remove_xpath
function! base#bufact#tml#remove_xpath ()
  call base#buf#start()

  call base#bufact#html#remove_xpath ()
endf

function! base#bufact#tml#r_win2unix ()
   try
      %s/\\/\//g
   catch
   endtry
endf

function! base#bufact#tml#r_unix2win ()
   try
      %s/\//\\/g
   catch
   endtry
endf

" rename attributes
"
function! base#bufact#tml#a_rename ()
  call base#html#htw_load_buf()

  let [ xpath, attr_rn ] = base#xml#a_rename_input ()

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

function! base#bufact#tml#a_delete ()
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
function! base#bufact#tml#quickfix_xpath ()
  call base#buf#start()

  call base#bufact#html#quickfix_xpath ()

endf

"""pretty_perl_libxml

function! base#bufact#tml#pretty_perl_libxml ()
  call base#buf#start()

  call base#bufact#html#pretty_perl_libxml ()

endf

