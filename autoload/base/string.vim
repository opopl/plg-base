
function! base#string#matchlist (string,pattern)
   let a = matchlist(a:string,a:pattern)
   if len(a)
      call remove(a,0)
   endif
   return a
endfunction

function! base#string#qq (string)
  return '"'.a:string.'"'
endfunction

function! base#string#expand_env (...)
  let str = get(a:000,0,'')

  if has('win32')
  elseif has('mac') || has('unix')
perl << EOF
  use Data::Dumper;

  my $str = VimVar('str');
  my @vars = ($str =~ /\$(\w+)/g);

  for my $var (@vars){
    my $val = $ENV{$var} || '';
    $str =~ s/\$$var/$val/g;
  }

  VimLet('str',$str);
EOF
  endif

  return str

endfunction

if 0
  usage
    let lst = base#string#split_trim('a dsgdfg ') | echo lst
endif

" {
function! base#string#split_trim (str,...)
  let opts = get(a:000,0,{})
  let str = a:str
python3 << eof
import vim
str  = vim.eval('str')

opts = vim.eval('opts')
sep  = opts.get('sep',' ')

if sep:
  lst = str.split(sep)
else:
  lst = list(str)

lst = list(map(lambda x: x.strip(), lst))
eof
  return py3eval('lst')

endfunction
" }

function! base#string#quote (string)
  return '"'.a:string.'"'
endfunction
