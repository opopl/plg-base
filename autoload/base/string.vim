
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

function! base#string#quote (string)
  return '"'.a:string.'"'
endfunction
