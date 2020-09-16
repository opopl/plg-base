"""BufAct_help_headers_list
function! base#bufact#help#headers_list ()
	call base#buf#start()

python3 << eof
import vim
import re
	
eof


endfunction


function! base#bufact#help#nicer ()
	try
		%s/​//g
	catch
	endtry
endfunction

function! base#bufact#help#replace_stars ()
	call base#buf#start()

	"perldo s/^\*([^*]*)\*/$1/gc
	%s/\*\([^*]*\)\*/\1/gc

endfunction
