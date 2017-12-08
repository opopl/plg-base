function! base#initpaths#apoplavskiynb ()
	
	 call base#pathset({ 
      \ "mingw" : base#file#catfile([ base#path('progs'), 'mingw' ]),
      \ "imagemagick" : base#file#catfile(base#qw('c: OSPanel modules imagemagick')),
	    \ })

	 call base#pathset({ 
			\	"perl_strawberry" : base#envvar("Perl_Strawberry"),
			\	"perl_activestate" : base#envvar("Perl_ActiveState"),
	    \ })

	 call base#pathset({ 
			\	"perl_lib_strawberry"  : base#qw#catpath('perl_strawberry','lib'),
			\	"perl_lib_activestate" : base#qw#catpath('perl_activestate','lib'),
	    \ })

	 call base#pathset({ 
      \ "perl_bin_strawberry_522_32" : base#file#catfile(
	 			\	[ 
	 			\	base#path('progs'), 
	 			\	base#qw('perl strawberry_522_32bit perl bin') 
	 		\	]),
	    \ })

endfunction