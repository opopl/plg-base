
function! base#vh#number_headings (...)
	let start = get(a:000,0,0)
	let end   = get(a:000,1,line('$'))

	let startnumber = input('Start number:','a')
	let endnumber   = input('End number:','z')

perl << eof
	BEGIN {$i=0; @a=($startnumber..$endnumber)}; if(/^\S(.+)/){ s/^(\S+)/$a[$i]. $1/g; $i++; }
	
eof
	
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


function! base#vh#act (start,end,...)
	let start = a:start
	let end   = a:end

	if !(&ft=='help')
		return
	endif

	let act = get(a:000,0,'')

	if strlen(act)
		let cmd = 'call base#vh#'.act.'(start,end)'
		exe cmd
	endif

endfunction
