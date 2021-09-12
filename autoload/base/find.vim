
function! base#find#py (...)
    let ref = get(a:000,0,{})

python3 << eof
import vim
import os,re,sys
from pathlib import Path
import Base.Util as util

found = []

ref = vim.eval('ref')

dirs    = ref.get('dirs',[])

relpath = ref.get('relpath',0)
ext     = ref.get('ext',[])
inc     = ref.get('inc',util.qw('dir file'))

for dir in dirs:
  d = Path(dir)
  for item in d.rglob('*'):
    full_path = str(item.as_posix())
    f = full_path
    if relpath:
      f = os.path.relpath(full_path,dir)

    ok = False
    for i in inc:
      ok = ok or (i == 'dir' and os.path.isdir(full_path))
      ok = ok or (i == 'file' and os.path.isfile(full_path))
      if ok:
        break

    if f and ok:
      found.append(f)

eof
  let found = py3eval('found')
  return found

endf

function! base#find#withperl (...)
    let ref = get(a:000,0,{})

    let prf={ 'func' : 'base#find#withperl','plugin' : 'base' }
    call base#log([
      \ 'ref => ' . base#dump(ref),
      \ ],prf)

    let exts_def = []

    let do_subdirs   = get(ref,'subdirs',1)
    let do_dirs_only = get(ref,'dirs_only',0)
    let pat          = get(ref,'pat','')

    let exts = get(ref,'exts',exts_def)
    if ! len(exts) | let exts=exts_def | endif

    let qw_exts = get(ref,'qw_exts','')
    if len(qw_exts)
      let exts = base#qw(qw_exts)
    endif

    let dirs = []
    let dirs = get(ref,'dirs',dirs)

    if get(ref,'cwd')
        call add(dirs,getcwd())
    endif

    let dirids    = []
    let qw_dirids = get(ref,'qw_dirids','')

    if len(qw_dirids)
      let dirids = base#qw(qw_dirids)
    endif

    let dirids = get(ref,'dirids',dirids)
    for id in dirids
        let dir = base#path(id)
        if len(dir)
          call add(dirs,dir)
        endif
    endfor

    if has('win32')
      let dirs = map(dirs,'base#file#win2unix(v:val)')
    endif

    " list of found files to be returned
    let foundfiles = []

    let files = []

    let olddir = getcwd()

perl << EOF
  use File::Find ();
  use Vim::Perl qw(:funcs :vars);
  use File::Spec::Functions qw(catfile);

  my $ref = VimVar('ref');

  my $dirs       = [ VimVar('dirs') ];
  my $exts       = [ VimVar('exts') ];

  my $pat                = VimVar('pat');
  my $pat_exclude        = $ref->{pat_exclude};

  my $do_subdirs = VimVar('do_subdirs');
  my $dirs_only  = VimVar('do_dirs_only');

  my @files=();

  my $pp = sub { @_ };
  unless ($do_subdirs) {
    unless ( $dirs_only) {
      $pp = sub { return grep { -f  } @_; };
    }else{
      my $max_depth = 1;
      $pp = sub {
        my $depth = $File::Find::dir =~ tr[/][];
        return grep { -d } @_ if $depth < $max_depth;
        return;
      };
    }
  }

  my (%qr,$s);
  if ($exts && @$exts) {
    $s  = '('. join('|',@$exts) . ')$';
    $qr{exts} = qr/$s/;
  }

  my $D;
  my $w = sub { 
    my $name  = $File::Find::name;

    my $add=1;

    if ($qr{exts}){
      $add   = 0 unless /$qr{exts}/;
    }

    if ( $pat && ! /$pat/ ){
      $add=0;
    }
    if($pat_exclude && /$pat_exclude/){
      $add=0;
    }
    $name=~s/\.\///g;
    return if $name eq '.';

    my $full_path = $D . '/' . $name ;
    if ($add){
      if ($ref->{relpath}) {
        push(@files,$name);
      }else{
        push(@files,$full_path);
      }
    }
  };

  for my $dir (@$dirs){
      $D = $dir;
      next unless -d $dir;
      chdir $dir;
      File::Find::find({ 
        wanted     => $w,
        preprocess => $pp,
      }, "." );
  }
  VimListExtend('files',[@files]);
EOF

  if has('win32')
    let files = map(files,'base#file#ossep(v:val)')
  endif

  let newfiles = []

  for file in files
    let add = 1
    let cf = copy(file)

    if get(ref,'rmext')
      for ext in exts
        let cf = substitute(cf,'\.'.ext.'$','','g') 
      endfor
    endif

    let fnm = get(ref,'fnamemodify','')
    if strlen(fnm)
      let cf = fnamemodify(cf,fnm)
    endif

    let cfname = fnamemodify(cf,':p:t')

    if add
      call add(newfiles,cf)
    endif
  endfor

  let map = get(ref,'map','')
  if strlen(map)
    call filter(newfiles,printf("'%s'",map))
  endif

  let mapsub = get(ref,'mapsub',[])
  if len(mapsub)
    let [ pat, subpat, subopts ]      = base#list#get(mapsub,'0:2')
    
    let newfiles = base#mapsub(newfiles,pat,subpat,subopts)
    
    call filter(newfiles,"'" . map . "'")
  endif

  "if get(ref,'relpath',0) && len(dirs)
    "let dir = get(dirs,0,'')
    "if isdirectory(dir)
      "let newfiles = map(newfiles,'base#file#reldir(v:val,dir)')
    "endif
  "endif

  let files = newfiles

  call extend(foundfiles,files)

  call filter(foundfiles,'v:val != ""')

  exe 'cd ' . olddir

  return foundfiles

  
endfunction

if 0
  call tree
    called by:
      projs#action#_plg_tex_view
      idephp#pj#act#symfony#twig_template_view
endif

function! base#find#open_split (...)
  let ref = get(a:000,0,{})

  let opts_find  = get(ref,'opts_find',{})
  let opts_split = get(ref,'opts_split',{})

  let dirs = get(opts_find,'dirs',[])

  let dir = get(dirs,0,'')
  let dir = get(opts_find,'dir',dir)

  let files = base#find(opts_find)
  let files = base#uniq(files)
  let files = sort(files)

  let info = []
  for file in files
    call add(info,[ file ])
  endfor

  let lines = [ get(opts_split,'title','')  ]
  call extend(lines,get(opts_split,'lines_before_table',[]))

  call extend(lines, pymy#data#tabulate({
    \ 'data'    : info,
    \ 'headers' : get(opts_split,'table_headers',['file']),
    \ }))
  
  let s:obj = {  'dir' : dir }
  function! s:obj.init (...) dict
    let r = {
        \  'dir'  : self.dir,
        \  'mode' : 'num',
        \  }
    call base#varset('ref_vis_act_open_file',r)

    resize 999
    vnoremap <silent><buffer> v :'<,'>call base#vis_act#open_file()<CR>
    
  endfunction
  
  let Fc = s:obj.init

  let stl_add = [
    \ '[ %3* v - view %0* ]'
    \ ]
  call base#buf#open_split({ 
    \ 'lines'   : lines,
    \ 'stl_add' : stl_add,
    \ 'Fc'      : Fc,
    \ })

endfunction
