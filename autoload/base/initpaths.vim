
function! base#initpaths#RESTPC ()
	 call base#pathset({ 
      \ "bin_mingw" : base#file#catfile([ base#path('progs'), 'mingw-w64', 'mingw32', 'bin' ]),
      \ "bin_vs_2005" : base#file#catfile([ base#path('pf'), 'Microsoft Visual Studio 8\VC\bin'  ]),
      \ "repos_git" : base#file#catfile([ base#path('hm'), 'repos', 'git'  ]),
	    \ })

	 call base#pathset({ 
      \ "localhost" : base#file#catfile([ base#path('repos_git'), 'localhost'  ]),
	 		\})

	 call base#pathset({ 
      \ "perl_strawberry" : base#file#catfile([ base#path('repos_git'), 'localhost'  ]),
	 		\})
endf

function! base#initpaths#php ()

	 call base#pathset({ 
      \ "urltotxt" : base#file#catfile([ base#path('localhost'), 'urltotxt' ]),
      \ "adminer_src" : base#file#catfile([ base#path('repos_git'), 'adminer_src' ]),
	    \ })
	
endfunction

function! base#initpaths#progs ()
	 let pc = base#pcname()

	 if pc == 'APOPLAVSKIYNB'
		 call base#pathset({ 
	      \ "prog_elinks" : base#file#catfile([ base#path('hm'), 'programs', 'browsers','elinks' ]),
		    \ })

	 elseif pc == 'RESTPC'
		 call base#pathset({ 
	      \ "xampp" : base#file#catfile([ base#path('hm'), 'programs', 'xampp' ]),
		    \ })

		 call base#pathset({ 
	      \ "mysql" : base#file#catfile([ base#path('xampp'), 'mysql'  ]),
		    \ })

	 endif
	
endfunction

function! base#initpaths#perl ()
		call base#log('call base#initpaths#perl')

	 call base#pathset({ 
      \ "htmltool" : base#file#catfile([ base#path('repos_git'), 'htmltool' ]),
	    \ })

	 call base#pathset({ 
			\	"perl_strawberry"  : base#envvar("Perl_Strawberry"),
			\	"perl_activestate" : base#envvar("Perl_ActiveState"),
	    \ })

	 call base#pathset({ 
      \ "plg_perlmy_scripts" : base#file#catfile([ base#path('plg'), 'perlmy', 'scripts' ]),
	    \ })

	 call base#pathset({ 
      \ "cpan_build_strawberry" : base#file#catfile([ base#path('perl_strawberry'), '..', 'cpan', 'build' ]),
      \ "cpan_install" : base#file#catfile(base#qw('C: install perl cpan')),
	    \ })

	 call base#pathset({ 
      \ "dancer_bookstore" : base#qw#catpath('perlmod','apps dancer bookstore'),
	    \ })

	 let pc = base#pcname()
	 if pc == 'APOPLAVSKIYNB'
			call base#pathset({ 
				\	 'install_cpan_pdl': 'C:\install\perl\cpan\PDL-2.018-0',
				\	})
	 endif
	
endfunction

function! base#initpaths#docs ()
		call base#log('call base#initpaths#docs')

		call base#pathset({ 
				\	 'materials_georgia_2017': 'C:\doc\sport_tourism\georgia_2017_khalaim\materials',
				\	 'gpx_georgia_2017'      : 'C:\doc\sport_tourism\georgia_2017_khalaim\materials\report\GPX_Georgia_2017\saved',
				\	})

		call base#pathset({ 
				\	'httpd_docs'  : 'C:\help\apache\httpd-docs-2.4.28.en',
				\	'sqlite_docs' : 'C:\help\sqlite\sqlite_doc',
				\})
	
endfunction

function! base#initpaths#APOPLAVSKIYNB ()
	 call base#pathset({ 
      \ "repos_git" : base#file#catfile([ base#path('hm'), 'repos', 'git'  ]),
	    \ })

	 call base#pathset({ 
      \ "household" : base#file#catfile([ base#path('repos_git'), 'household'  ]),
	    \ })

	 call base#pathset({ 
      \ "ospanel_config" : base#file#catfile(base#qw('c: OSPanel userdata config')),
	    \ })

	 call base#pathset({ 
      \ "install" : base#file#qw('C: install'),
	    \ })

	 call base#pathset({ 
      \ "c_work" : base#file#catfile([ 'C:', 'work'  ]),
      \ "work_gpx_georgia_2017" : base#file#catfile([ 'C:', 'work', 'georgia_2017', 'gpx'  ]),
	    \ })


	 call base#pathset({ 
			\ 'sql_data' : 	'C:\Users\apoplavskiy\data\sql_data',
	 		\})
	
	 call base#pathset({ 
      \ "mingw"       : base#file#catfile([ base#path('progs'), 'mingw' ]),
      \ "imagemagick" : base#file#catfile(base#qw('c: OSPanel modules imagemagick')),
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
