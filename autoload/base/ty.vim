
function! base#ty#make (...)
	let ref = get(a:000,0,{})

	let dirs  = get(ref,'dirs',[])
	let tfile = get(ref,'tfile','')

	let ok = 1

	let max_node_count = input('max_node_count:','')

perl << eof
	use String::Escape qw(escape);

	my $dirs    = VimVar('dirs');
	my $tfile   = VimVar('tfile');
	my $max_node_count = VimVar('max_node_count');

	my $ok=1;

	my %o = (
		dirs    => $dirs,
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
	$o->{max_node_count} = $max_node_count if $max_node_count; 

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

	return ok
	
endfunction
