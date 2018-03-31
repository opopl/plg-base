
"""VH_index_headings
function! base#vh#index_headings (...)
	let start = get(a:000,0,1)
	let end   = get(a:000,1,line('$'))

	let startid = input('Start id:','a')
	let endid   = input('End id:','z')

	let pat     = input('Perl heading regexp:','^(\S.+)')

perl << eof
	use Vim::Perl qw(VimVar);

	my $start = VimVar('start');
	my $end   = VimVar('end');
	my @range = ( $start .. $end );

	my $pat   = VimVar('pat');
	my $patqr = qr/$pat/;

	my $startid = VimVar('startid');
	my $endid   = VimVar('endid');

	my @a = ( $startid .. $endid ); 

	my $lines = [ $curbuf->Get( @range ) ];
	my $lnum=1;
	for(@$lines){
		if(/$patqr/){ 
			my $a=shift @a;
			s/$patqr/"$a. ". $1/eg; 
			$curbuf->Set($lnum,$_);
		}
		$lnum++;
	}
	
eof
	
endfunction

function! base#vh#remove_headings (...)
	let start = get(a:000,0,1)
	let end   = get(a:000,1,line('$'))

	let head_fmt = input('Heading perl regexp format:','^(\w+\.\s+)' )

perl << eof
	use Vim::Perl qw(VimVar);

	my $start = VimVar('start');
	my $end   = VimVar('end');
	my @range = ( $start .. $end );

	my $lines = [ $curbuf->Get( @range ) ];
	my $lnum=1;
	my $head_fmt = VimVar('head_fmt');
	my $pat = qr/$head_fmt/;
	
	for(@$lines){
		if(/$pat/){ 
			s/$pat//g; 
			$curbuf->Set($lnum,$_);
		}
		$lnum++;
	}
	
eof
	
endfunction

function! base#vh#tag_from_basename (...)
	call base#buf#start()

	let tag = b:basename
	let tag = substitute(tag,'\.\w\+$','','g')

	call append(line(0),'*'.tag.'*')

endfunction

function! base#vh#prompt_arabic (...)
	let start = get(a:000,0,0)
	let end   = get(a:000,1,line('$'))

	let startletter = input('Start letter:','a')
	let endletter   = input('End letter:','z')

perl << eof
	my @a = (VimVar('startletter')..VimVar('endletter'));

	# number of lines in the current buffer
	my $n=$curbuf->Count();

	# start line number
	my $start = VimVar('start');

	# end line number
	my $end = VimVar('end');

	# running line number
	my $lnum=$start;

	# heading index
	my $nhead=0;

	while ( !( $lnum == $end ) ) {
			local $_=$curbuf->Get($lnum);
			
			/^\S(.+)/ && do { 
					s/^(\S+)/$a[$nhead]. $1/g; 
					$nhead++;

					$curbuf->Set($lnum,$_);
			};
			$lnum++;
	}

eof

endfunction

"call base#vh#act (act,start,end)
"call base#vh#act (act)
"
function! base#vh#heads_handle (...)

	let pats = {
		\ 'head_1' : input('pattern head_1:','^(\w+)\.\s+(.*)$'),
		\ 'head_2' : input('pattern head_2:','^\s{2,2}(\S.*)$'),
		\	}

	let index_h2_start = input('H2 index start:','a')
	let index_h2_end   = input('H2 index end:','z')

	let refprefix = input('refprefix:','thisdoc_______')
	let buf_rw    = input('buffer rewrite? (1/0): ',0)

perl << eof
	my $i=0;

	my $pats       = VimVar('pats');

	my $index_h2_start =  VimVar('index_h2_start') || 'a';
	my $index_h2_end   =  VimVar('index_h2_end')   || 'z';

	my $refprefix = VimVar('refprefix') || 'thisdoc____';

	my @indices_h2 = ( $index_h2_start .. $index_h2_end );

	my $lines = [ $curbuf->Get( 1 .. $curbuf->Count ) ];

	my @heads;

	my $lnum=1;
	my ($last_h1,$last_h2);

	my $j_h2=0;
	my $i_h1=0;
	my @toc;

	my @nlines;
	my (@before);
	my $before_first_sec=1;

	my $target;
	for(@$lines){
		$target='';

		/^$pats->{head_1}/ && do { 
			my ($index,$title) = ($1,$2);

			$before_first_sec=0;

			$last_h1 = { 
					'lnum'     => $lnum,
					'index'    => $index,
					'title'    => $title,
					'children' => [],
			};
			push @heads,$last_h1;

			my $h1 = join(" ",$index,$title);

			my $fmt = 'A50A*';

			$i_h1++;

			my $ref = $refprefix.$index;
			$ref=~s/[\.-]/_/g;

			$target = "*".$ref."*";

			push @toc, pack($fmt, $h1 , '|'.$ref.'|' );

			#reset subheading (h2) index
			$j_h2=0;

		};
		/^$pats->{head_2}/ && do { 
			my $title = $1;

			my $sub_index_h2 = $indices_h2[$j_h2];
			$j_h2++;

			my $index = join('.', $last_h1->{index},  "$sub_index_h2" );  

			my $fmt = 'A50A*';

			my $h2  = join(" ",$index,$title);
			my $ref = $refprefix.$index;
			$ref=~s/[\.-]/_/g;

			push @toc, pack($fmt, "  ".$h2 , '|'.$ref.'|' );
			$target="*".$ref."*";

			$last_h2 = { 
					'lnum'     => $lnum,
					'index'    => $index,
					'title'    => $title,
					'children' => [],
					parent     => { 
						title => $last_h1->{title} ,
						lnum  => $last_h1->{lnum} ,
					},
			};

			my $children = $last_h1->{children} || [];
			push @$children, $last_h2;

		};
		$lnum++;

		unless($before_first_sec){
			push @nlines,$_;
		}else{
			push @before,$_;
		}

		if( $target ){
			push @nlines,' ' . $target;
		}
	}

	my @delim=( '-' x 50 );
	@toc = ( @delim, 'Table of Contents', @delim, @toc, @delim );

	unshift @nlines,
		( @before,@toc );

	if ( VimVar('buf_rw') ) {
		CurBufSet({ curbuf => $curbuf, text => [@nlines]});
	}
eof

endfunction


function! base#vh#act (...)
	if !(&ft=='help')
		return
	endif

	let start = 1
	let end   = line('$')
	if base#vim#in_visual_mode ()
		let start = get(a:000,1,1)
		let end   = get(a:000,2,line('$'))
	endif

	let act = get(a:000,0,'')

	if strlen(act)
		let cmd = 'call base#vh#'.act.'(start,end)'
		exe cmd
	endif

endfunction
