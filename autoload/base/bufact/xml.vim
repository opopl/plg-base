
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

function! base#bufact#xml#r_win2unix ()
   try
      %s/\\/\//g
   catch
   endtry
endf

function! base#bufact#xml#r_unix2win ()
   try
      %s/\//\\/g
   catch
   endtry
endf

" rename attributes
"
function! base#bufact#xml#a_rename ()
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

function! base#bufact#xml#update_var ()
  call base#buf#start()

  if exists("b:plg")
    let plg_dir = base#path('plg')
    let reldir  = base#file#reldir(b:dirname, plg_dir)
    let reldir  = base#file#win2unix(reldir)

python << eof
import vim,re

reldir = vim.eval('reldir')
b_plg  = vim.eval('b:plg')

m = re.match(r'^(\w+)/(.*)$',reldir)
plg = ''
inner = ''
if m:
  plg   = m.group(1)
  inner = m.group(2)
 
print(plg)
print(inner)
eof
  endif

endf
