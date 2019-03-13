
function! base#dump#py (thing)
python << eof
import vim
thing = vim.eval('a:thing')
eof
	
endfunction
