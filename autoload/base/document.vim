
function! base#document#add_to_db ()

perl << eof
	our $D = Base::Document->new;
	
eof
	
endfunction
