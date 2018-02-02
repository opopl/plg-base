
function! base#initpaths#restpc ()
	 call base#pathset({ 
      \ "bin_mingw" : base#file#catfile([ base#path('progs'), 'mingw-w64', 'mingw32', 'bin' ]),
      \ "bin_vs_2005" : base#file#catfile([ base#path('pf'), 'Microsoft Visual Studio 8\VC\bin'  ]),
	    \ })
endf

function! base#initpaths#apoplavskiynb ()
	
	 call base#pathset({ 
      \ "mingw" : base#file#catfile([ base#path('progs'), 'mingw' ]),
      \ "imagemagick" : base#file#catfile(base#qw('c: OSPanel modules imagemagick')),
	    \ })

	 call base#pathset({ 
			\	"perl_strawberry"  : base#envvar("Perl_Strawberry"),
			\	"perl_activestate" : base#envvar("Perl_ActiveState"),
	    \ })

	 let saved_html = base#file#catfile(base#qw('c: saved html'))

	 call base#pathset({ 
			\	"saved_html" : base#envvar("saved_html",saved_html),
	 		\	})

	 call base#pathset({
	 		\	'perl_tk_demos' : 'C:\strawberry\perl\site\lib\Tk\demos\widget_lib',
			\	})
	 

	 call base#pathset({ 
			\	'pgdata' : 'C:\OSPanel\modules\database\PostgreSQL-9.6-x64\data',
	 		\	})

	 call base#pathset({ 
			\	"perl_lib_strawberry"  : base#qw#catpath('perl_strawberry','lib'),
			\	"perl_lib_activestate" : base#qw#catpath('perl_activestate','lib'),
	    \ })

   call base#pathset({ 
      \ "georgia_2016" : base#file#catfile([ 'c:', 'doc', 'sport_tourism', 'georgia_2016_trylis']),
      \ })

   call base#pathset({ 
	 		\	'books_conf_work' : 'C:\web\books\books.conf.work\books',
	 		\} )

	 call base#pathset({ 
      \ "perl_bin_strawberry_522_32" : base#file#catfile(
	 			\	[ 
	 			\	base#path('progs'), 
	 			\	base#qw('perl strawberry_522_32bit perl bin') 
	 		\	]),
	    \ })

	 call base#pathset({ 
			\	"photos_georgia_2016" : base#file#catfile(base#qw('c: doc photos georgia_2016')),
	    \ })

    call base#pathset({
        \   'open_server' : base#file#catfile(base#qw('C: OSPanel')),
				\	})

    call base#pathset({
				\ 'localhost'     : base#qw#catpath('open_server','domains localhost'),
				\	})

    call base#pathset({
				\ 'url_articleloader' : base#qw#catpath('localhost','articleloader'),
				\ 'url_photoloader'   : base#qw#catpath('localhost','photoloader'),
				\	})

		call base#pathset({
			\	'web_mdn_HTML_elements_reference' : 
				\	'C:\web\MDN_HTML_elements_reference\developer.mozilla.org\en-US\docs\Web\HTML\Element'
				\	})

endfunction
