
function! base#find#withperl (...)
    let ref = get(a:000,0,{})

		let prf={ 'prf' : 'base#find#withperl' }
		call base#log([
			\	'ref => ' . base#dump(ref),
			\	],prf)

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
			$pp =	sub { return grep { -f  } @_; };
		}else{
			my $max_depth = 1;
			$pp =	sub {
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
      $D=$dir;
      next unless -d $dir;
	  	chdir $dir;
	  	File::Find::find({ wanted => $w, preprocess => $pp}, "." );
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
		call filter(newfiles,"'" . map . "'")
	endif

	let mapsub = get(ref,'mapsub',[])
	if len(mapsub)
		let [pat,subpat,subopts]      = base#list#get(mapsub,'0:2')
		
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
