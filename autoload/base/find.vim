
function! base#find#withperl (...)
    let ref = get(a:000,0,{})

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

    " list of found files to be returned
    let foundfiles = []

    let files = []

    let olddir = getcwd()

perl << EOF
  use File::Find ();
  use Vim::Perl qw(:funcs :vars);

  my $dirs       = [ VimVar('dirs') ];
  my $exts       = [ VimVar('exts') ];

  my $pat        = VimVar('pat');
  my $do_subdirs = VimVar('do_subdirs');

  my @files=();

	my $pp = ($do_subdirs) ? sub { @_ } : sub { return grep { -f  } @_; };

	my (%qr,$s);
	if ($exts && @$exts) {
		$s  = '('. join('|',@$exts) . ')$';
		$qr{exts} = qr/$s/;
	}

  my $w = sub { 
		my $name  = $File::Find::name;

		return if -d;

		my $add=1;

    if ($qr{exts}){
			$add   = 0 unless /$qr{exts}/;
    }

    if ( $pat && ! /$pat/ ){
			$add=0;
    }

    push(@files,$name) if $add;
  };

  File::Find::find({ wanted => $w, preprocess => $pp }, @$dirs );
	VimListExtend('files',[@files]);
EOF

  call filter(files,'v:val != ""')
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

	if get(ref,'relpath',0) && len(dirs)
		let dir = get(dirs,0,'')
		if isdirectory(dir)
			let newfiles = map(newfiles,'base#file#reldir(v:val,dir)')
		endif
	endif

	let files = newfiles
	call extend(foundfiles,files)

	exe 'cd ' . olddir

	return foundfiles

	
endfunction
