
"  base#tg#set (id)
"  base#tg#set ()
"

function! base#tg#set (...)
	if a:0 | let tgid = a:1 | endif

	let ref = {}
	if a:0 > 1 | let ref = a:2 | endif

	let tfile = base#tg#tfile(tgid)

	if tgid == 'this'
	elseif tgid == 'thisfile'
	endif

	if get(ref,'update_ifabsent',1)
		if !filereadable(tfile)
			call base#tg#update(tgid)
		endif
	endif

	let tfile=escape(tfile,' \')
	exe 'setlocal tags=' . tfile
	let b:tgids=[tgid]
	
endfunction

function! base#tg#go (...)
	let tgs = get(a:000,0,'')
	let ref = get(a:000,1,{})

	let tg=''
	if base#type(tgs) == 'String'
		let tg=tgs
		
	elseif base#type(tgs) == 'List'
		for tg in tgs
			call base#tg#go(tg,ref)
		endfor
		return
	endif

	let after = get(ref,'after',[])
	let before = get(ref,'before',[])

	for cmd in before
		try
			exe cmd
		endtry
	endfor

	try
			exe 'tag '. tg
	endtry

	for cmd in after
		try
			exe cmd
		endtry
	endfor

		"catch /^Vim\%((\a\+)\)\=:E684

endfunction

function! base#tg#add (...)
	if a:0 | let tgid = a:1 | endif

	let tfile = base#tg#tfile(tgid)

	let tfile=escape(tfile,' \')
	exe 'setlocal tags+=' . tfile
	let tgs = base#tg#ids() 
	call add(tgs,tgid)

	let tgs     = base#uniq(tgs)
	let b:tgids = tgs

endf


function! base#tg#ids (...)
	if exists("b:tgids")
		let tgids=b:tgids
	else
		let tgids=[]
	endif

	return tgids

endf

function! base#tg#ids_comma (...)
	let tgids = base#tg#ids()

	if ( (type(tgids) == type([])) && len(tgids) )
		return join(tgids,',')
	endif
	return ''

endf


function! base#tg#tfile (...)
	if a:0 | let tgid = a:1 | endif

	let tdir = base#path('tagdir')

	call base#mkdir(tdir)

"""_tfile_thisfile
	if tgid == 'thisfile'
		let finfo    = base#getfileinfo()

		let dirname  = get(finfo,'dirname','')
		let basename = get(finfo,'filename','')

		let tfile    = base#file#catfile([ dirname, basename . '.tags' ])

"""_tfile_projs_this
	elseif tgid == 'projs_this'
		let proj  = projs#proj#name()
		let tfile = projs#path([ proj . '.tags' ])

"""_tfile_idephp_help
	elseif tgid == 'idephp_help'
		let tfile = base#qw#catpath('plg','idephp help tags')

	elseif tgid == 'help_perlmy'
		let tfile = base#qw#catpath('plg','perlmy doc tags')

	else
		let tfile = base#file#catfile([ tdir, tgid . '.tags' ])
	endif

	return tfile
endf

"call base#tg#update (tgid)
"call base#tg#update ()

function! base#tg#update (...)
	let opts = get(a:000,1,{})

	if a:0 
		let tgid = a:1
	else
		let tgs = base#tg#ids()
		for tgid in tgs
			call base#tg#update(tgid,{ 'add' : 1 })
		endfor
		return
	endif

	let refsys = {}

	"" stored in the corresponding dat-file
	let tgs_all = base#varget('tagids',[])

	" tagfile full path
	let tfile = base#tg#tfile(tgid)

	let libs  = ''

	" list of files
	let files = ''

	" file with the list of files
	let filelist = ''

	let libs_as = join(base#qw("C:/Perl/site/lib C:/Perl/lib" ),' ')

	if tgid  == ''

"""tgupdate_idephp_help
	elseif tgid == 'idephp_help'
		call idephp#help#helptags({ 
			\	'tfile' : tfile 
			\	})

		let okref = { 
			\	"tgid" : tgid,
			\	"ok"   : 1,
			\	"add"  : 0, 
			\	}

		let ok= base#tg#ok(okref)
		return

	elseif tgid == 'ty_perl_htmltool'
			let dir = base#path('htmltool')
			let lib = base#file#catfile([ dir, 'lib' ])

perl << eof
	use String::Escape qw(escape);

	my $lib     = VimVar('lib');
	my $tfile   = VimVar('tfile');

	my $ok=1;

	my %o = (
		dirs    => [$lib],
		tagfile => $tfile,
		sub_log  => sub { 
			VimLog(@_); 
			#VimMsg([@_]); 
		},
		sub_warn => sub { 
			VimLog(@_); 
			VimWarn(@_); 
		},
	);

	eval { 
		use Base::PerlFile;

		VimLog('Running Base::PerlFile...');

		my $pf =  Base::PerlFile->new(%o);
		$pf
			->load_files_source
			->ppi_list_subs
			->tagfile_rm
			->write_tags
			;
	};
	if($@){
		VimWarn($@);
		my $s = escape('printable',$@);
		VimCmd(qq{ call base#log("$s") });
		$ok=0;
	}
	VimLet('ok',$ok);
eof

		let okref = { 
			\	"tgid" : tgid,
			\	"ok"   : ok,
			\	"add"  : 0, 
			\	}

		let ok= base#tg#ok(okref)
		return

"""tgupdate_help_perlmy
	elseif tgid == 'help_perlmy'
		call perlmy#help#helptags()

		let okref = { 
			\	"tgid" : tgid,
			\	"ok"   : 1,
			\	"add"  : 0, 
			\	}

		let ok= base#tg#ok(okref)
		return

"""tgupdate_help_plg_perlmy
	elseif tgid == 'help_plg_perlmy'
 "   call idephp#help#helptags()

		"let okref = { 
			"\	"tgid" : tgid,
			"\	"ok"   : 1,
			"\	"add"  : 0, 
			"\	}

		"let ok= base#tg#ok(okref)
		return

"""tgupdate_src_vim
	elseif tgid == 'src_vim'
		let dir_src = base#qw#catpath('src_vim', 'src')
		let dirs    = []

		call add(dirs,dir_src)
		call add(dirs,base#path('include_win_sdk'))

    let files_arr = base#find({ 
			\	"dirs"    : dirs,
			\	"exts"    : base#qw('c h'),
			\	"relpath" : 0,
			\ })

		let files = join(files_arr,' ')

"""tgupdate_php_adminer_src
	elseif tgid == 'php_adminer_src'
		let f     = idephp#pj#files_tags('adminer_src')
		call map(f,'base#file#win2unix(v:val)')
		let files = join(f,' ')

		let filelist = base#qw#catpath('plg','idephp pj files_tags '.tgid.'.txt')

		call base#file#write_lines({ 
			\	'lines' : f, 
			\	'file'  : filelist, 
			\})

		let a=[]

		call extend(a,[ 'ctags','-R -o' ] )
		call extend(a,[ base#string#qq( ap#file#win( tfile ) ) ] )
		call extend(a,[ libs ])
		call extend(a,[ '-L',base#string#qq(filelist) ] )
		
		let cmd = join(a," ")

		echo "Calling ctags command for: " . tgid 

		call extend(refsys,{ 'cmds' : [ cmd ] })
		let ok = base#sys(refsys)

		let okref = { 
				\	"cmd"  : cmd,
				\	"tgid" : tgid,
				\	"ok"   : ok,
				\	"add"  : get(opts,'add',0) }

		let ok= base#tg#ok(okref)
	
		return  ok

"""tgupdate_php_urltotxt
	elseif tgid == 'php_urltotxt'

		let dir   = base#path('urltotxt')
		let libs .= ' ' . dir

"""tgupdate_perl_htmltool
	elseif tgid == 'perl_htmltool'

		let dir   = base#file#catfile([ base#path('htmltool'), 'lib' ])
		let libs .= ' ' . dir

	elseif tgid == 'perl_guestbook'
		let dir   = base#file#catfile([ base#path('repos_git'), 'guestbook', 'lib' ])
		let libs .= ' ' . dir

	elseif tgid == 'perl_webgui'

		let dir   = 'c:\src\webgui-master\lib'
		let libs .= ' ' . dir

"""tgupdate_perl_as
	elseif tgid == 'perl_as'

		let libs.=' ' . libs_as

	elseif tgid == 'perl_inc_plg_browser'

		let dir   = base#file#catfile([ base#path('plg'), 'browser', 'perl' ])
		let libs .= ' ' . dir

	elseif tgid == 'perl_inc_plg_base'

		let dir   = base#file#catfile([ base#path('plg'), 'base', 'perl', 'lib' ])
		let libs .= ' ' . dir

"""tgupdate_perl_inc_select
	elseif tgid == 'perl_inc_select'
		let mods = base#varget('perlmy_mods_perl_inc_select',[])
		let locs = {}

		for mod in mods
			let cmd = 'pminst -l '.mod

			let ok  = base#sys({ "cmds" : [cmd]})
			let out = base#varget('sysout',[])

			call extend(locs,{ mod : out })
		endfor

		let json = base#json#encode(locs)

"""tgupdate_perl_inc
	elseif tgid == 'perl_inc'

		let a = base#envvar_a('perllib')
		let a = perlmy#perl#inc_a()
		"let libs=join( map ('ap#file#win(a:val)',a) )
		let libs = join(a,' ')

		let cnt = input('(TgUpdate perl_inc) Continue? 1/0: ',0)
		if !cnt
			return
		endif

"""basetg_update_mkvimrc
	elseif tgid =~ 'mkvimrc'

		let dir = base#path('mkvimrc')
		let cwd = getcwd()

		let files_arr = base#find({ 
			\	"dirs"    : [ dir ],
			\	"exts"    : [ "vim"  ],
			\	"relpath" : 0,
			\ })

		let files = join(files_arr,' ')

"""basetg_update_plg
	elseif tgid == 'plg'
		let lines = []
		for tg in tgs_all
			if tg !~ '^plg_' | continue | endif

			let tf = base#tg#tfile(tg)
			if !filereadable(tf)
				call base#tg#update(tg)
			endif
			let l = readfile(tf)
			call extend(lines,l)
		endfor
		let lines = sort(lines)

		call writefile(lines,tfile)
		unlet lines

		if get(opts,'add',0)
			call base#tg#add(tgid)
		else
			call base#tg#set(tgid)
		endif

		return 1

"""basetg_update_plg_
	elseif tgid =~ '^plg_'
		"let pat = '^plg_\(\w\+\)$'
		let pat = '^plg_\(.\+\)$'
		let plg = substitute(tgid,pat,'\1','g')

		let plgdir = base#catpath('plg',plg)

		let files_arr = base#find({ 
			\	"dirs" : [ plgdir ], 
			\	"exts" : [ "vim"  ], 
			\ })
		let files = join(files_arr,' ')

"""tgupdate_projs_tex
	""" all tex files in current projs directory
	elseif tgid == 'projs_tex'
			if base#plg#loaded('projs')
				let root = projs#root()
		
			   " let files_tex = base#find({ 
					"\	"dirs" : [ root ], 
					"\	"exts" : [ "tex"  ], 
					"\ })
				"let files = join(files_tex,' ')
				"echo files
				let files = base#file#catfile([ root,'*.tex' ])
			endif

"""tgupdate_projs_this
	elseif tgid == 'projs_this'
		if base#plg#loaded('projs')
				let proj  = projs#proj#name()
				let exts  = base#qw('tex vim bib')
		
				let files_arr = projs#proj#files({ 
					\	"exts"         : exts,
					\	"exclude_dirs" : [ 'joins', 'builds' ],
					\	})
		
				let files = join(files_arr,' ')
		
				let tfile = projs#path([ proj . '.tags' ])
		
				call projs#rootcd()
		endif

	elseif tgid == 'perlmod'
		let id = tgid

		call base#CD(id)

		let libs=join( [ 
			\	ap#file#win( base#catpath(id,'lib') ), 
			\	] ," ")

		"let libs.=' ' . libs_as

"""thisfile
"""tgupdate_thisfile
	elseif tgid == 'thisfile'
		let files.= ' ' . expand('%:p')
	else 
		call base#warn({"text" : "unknown tagid!"})
		return 0
	endif

"""tgupdate_cmd_ctags
	let cmd = 'ctags -R -o "' . ap#file#win( tfile ) . '" ' . libs . ' ' . files
	call base#varset('last_ctags_cmd',cmd)

	echo "Calling ctags command for: " . tgid 

	call extend(refsys,{ 'cmds' : [ cmd ] })
	let ok = base#sys(refsys)

	let okref = { 
			\	"cmd"  : cmd,
			\	"tgid" : tgid,
			\	"ok"   : ok,
			\	"add"  : get(opts,'add',0) }

	let ok= base#tg#ok(okref)

	return  ok
endfunction

function! base#tg#ok (...)
	let okref = {}
	if a:0 | let okref = a:1 | endif

	let ok   = get(okref,'ok','')
	let tgid = get(okref,'tgid','')
	let add  = get(okref,'add',0)

	if ok
		redraw!
		echohl MoreMsg
		echo "CTAGS UPDATE OK: " .  tgid
		echohl None

		let h = { "update_ifabsent" : 0 }
		if add 
			call base#tg#add (tgid,h)
		else
			call base#tg#set (tgid,h)
		endif

	else
		redraw!
		echohl Error
		echo "CTAGS UPDATE FAIL: " .  tgid
		echohl None
	endif

	return ok
	
endfunction

function! base#tg#view (...)

	if a:0 
		let tgid = a:1
	else
		let tgs = base#tg#ids()
		for tgid in tgs
			call base#tg#view(tgid)
		endfor
		return
	endif

	let tfile = base#tg#tfile(tgid)

	if !filereadable(tfile)
		call base#tg#update(tgid)
	endif

	call base#fileopen(tfile)

	let tfile=escape(tfile,' \')
	exe 'setlocal tags+='.tfile
	
endfunction
