
function! base#ty#make (...)
	let ref = get(a:000,0,{})

	let dirs  = get(ref,'dirs',[])
	let tfile = get(ref,'tfile','')

	let ok = 1

	let max_node_count = input('max_node_count:','')

perl << eof
	use String::Escape qw(escape);

	my $dirs           = VimVar('dirs');
	my $tfile          = VimVar('tfile');

	my $max_node_count = int ( VimVar('max_node_count') || 0 );
	$max_node_count = 10;

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
		add => [qw( subs packs )],
	);

	$o{max_node_count} = $max_node_count if $max_node_count; 

	my $s = sub {
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
	};

	eval { 
	    local $SIG{ALRM} = sub { die "alarm clock restart" };
	    alarm 10;                   # schedule alarm in 10 seconds 
	    eval { $s->(); };
	    alarm 0;                    # cancel the alarm
	};
	alarm 0;                        # race condition protection
	die if $@ && $@ !~ /alarm clock restart/; # reraise	
eof

	return ok
	
endfunction
