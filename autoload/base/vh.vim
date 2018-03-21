
function! base#vh#number_headings (...)
	let start = get(a:000,0,1)
	let end   = get(a:000,1,line('$'))

	let startid = input('Start id:','a')
	let endid   = input('End id:','z')

perl << eof
	use Vim::Perl qw(VimVar);

	my $start = VimVar('start');
	my $end   = VimVar('end');
	my @range = ( $start .. $end );

	my $startid = VimVar('startid');
	my $endid   = VimVar('endid');

	my @a = ( $startid .. $endid ); 

	my $lines = [ $curbuf->Get( @range ) ];
	my $lnum=1;
	for(@$lines){
		if(/^\S(.+)/){ 
			my $a=shift @a;
			s/^(\S.+)/"$a. ". $1/eg; 
			$curbuf->Set($lnum,$_);
		}
		$lnum++;
	}
	
eof
	
endfunction

function! base#vh#remove_headings (...)
	let start = get(a:000,0,1)
	let end   = get(a:000,1,line('$'))

	let head_fmt = input('Heading perl regexp format:','(\w+\.\s+)' )

perl << eof
	use Vim::Perl qw(VimVar);

	my $start = VimVar('start');
	my $end   = VimVar('end');
	my @range = ( $start .. $end );

	my $lines = [ $curbuf->Get( @range ) ];
	my $lnum=1;
	my $head_fmt = VimVar('head_fmt');
	my $pat = qr/^$head_fmt/;
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
