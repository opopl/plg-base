
function! base#ty#make (...)
	let ref = get(a:000,0,{})

	let dirs  = get(ref,'dirs',[])
	let tfile = get(ref,'tfile','')

	let ok = 1

perl << eof
	use String::Escape qw(escape);

	my $dirs           = VimVar('dirs');
	my $tfile          = VimVar('tfile');

	my $ok=1;

	my %o = (
		dirs    => $dirs,
		tagfile => $tfile,
		sub_log  => sub { 
			VimLog(@_); 
		},
		sub_warn => sub { 
			VimLog(@_); 
			VimWarn(@_); 
		},
		add => [qw( subs packs vars include )],
	);

	my $s = sub {
		eval { 
			use Base::PerlFile;
	
			VimLog('Running Base::PerlFile...');
	
			my $pf =  Base::PerlFile->new(%o);
			$pf
				->load_files_source
				->ppi_process
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
	};
	$s->();

eof

	return ok
	
endfunction
