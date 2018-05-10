
function! base#find#withperl (...)
    let ref = get(a:000,0,{})

    let exts_def = [ '' ]

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

  my @dirs       = VimVar('dirs');
  my @exts       = VimVar('exts');

  my $pat        = VimVar('pat');
  my $do_subdirs = VimVar('do_subdirs');

  my @files=();

  my $w = sub { 
    my ($ext) = (/\.(\w+)$/);
		my $name = $File::Find::name;

		my $add=1;

		return unless -e $name; 

		$File::Find::prune = ($do_subdirs) ? 0 : 1;

    if ( @exts && ! grep { /^$ext$/ } @exts ){
			$add=0;
    }

    if ( $pat && ! /$pat/ ){
			$add=0;
    }

    push(@files,$name) if $add;
  };

  File::Find::find({ wanted => $w }, @dirs );
	VimListExtend('files',[@files]);
EOF

  call filter(files,'v:val != ""')

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

	let files = newfiles
	call extend(foundfiles,files)

	exe 'cd ' . olddir

	return foundfiles

	
endfunction
