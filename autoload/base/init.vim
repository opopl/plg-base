
fun! base#init#cmds_plg ()

"""PlgAct
	command! -nargs=* -complete=custom,base#complete#plg_with_all PlgAct
		\	call base#plg#act(<f-args>) 

"""PlgView
	command! -nargs=* -complete=custom,base#complete#plg PlgView 
		\	call base#plg#view(<f-args>) 

"""PlgHelp
	command! -nargs=* -complete=custom,base#complete#plg PlgHelp
		\	call base#plg#help(<f-args>) 

"""PlgGrep
	command! -nargs=* -complete=custom,base#complete#plg_with_all PlgGrep
		\	call base#plg#grep(<f-args>) 

"""PlgCD
	command! -nargs=* -complete=custom,base#complete#plg PlgCD 
		\	call base#plg#cd(<f-args>) 

"""PlgRuntime
	command! -nargs=* -complete=custom,base#complete#plg PlgRuntime
		\	call base#plg#runtime(<f-args>) 

"""PlgNew
	command! -nargs=* -complete=custom,base#complete#plg PlgNew
		\	call base#plg#new(<f-args>) 

"""PlgList
	command! -nargs=* -complete=custom,base#complete#plg PlgList
		\	call base#plg#echolist(<f-args>) 

endf


"""base_initpaths

"call base#initpaths()
"call base#initpaths({ "anew": 1 })

fun! base#init#paths(...)
    call base#echoprefix('(base#init#paths)')

		let vrt = base#envvar('VIMRUNTIME')
		let plg = base#file#catfile([  vrt, 'plg'  ])

    call base#pathset({  'plg' : plg })

		let dir = base#file#catfile([  vrt, 'plg', 'base'  ])
		
		call base#varset('plgdir',dir)
		call base#datadir( base#file#catfile([ dir, 'data' ]) )

    let ref = {}
    if a:0 | let ref = a:1 | endif

    let home     = base#envvar( (has('win32')) ? 'USERPROFILE' : 'HOME' )
    let hm       = base#envvar('hm',home)

    let pc       = base#envvar((has('win32')) ? 'USERPROFILE' : get(split(system('hostname'),"\n"),0) )

		let p = base#paths_from_db()
		if len(p)
			return
		endif

		if has('win32')
			let pf       = base#envvar('PROGRAMFILES')

			call base#pathset({ 
          \ 'pf'            : pf ,
	        \ 'include_win_sdk'   : base#envvar('INCLUDE_WIN_SDK'),
					\})
		endif

    let vrt      = base#envvar('VIMRUNTIME')
    let projsdir = base#envvar('PROJSDIR')

    call base#pathset({ 
        \ 'home'          : home ,
        \ 'hm'            : hm ,
        \ 'vrt'           : vrt,
        \ 'vim'           : base#envvar('VIM'),
        \ 'conf'          : base#envvar('CONFDIR'),
        \ 'src_vim'       : base#envvar('SRC_VIM'),
        \ 'texdocs'       : projsdir,
        \ 'texinputs'     : base#envvar('texinputs'),
        \ 'p'             : base#envvar('TexPapersRoot'),
        \ 'phd_p'         : base#envvar('TexPapersRoot'),
        \ 'tagdir'        : base#file#catfile([ hm,'tags' ]),
				\ 'appdata'       : base#envvar('APPDATA'),
				\ 'appdata_local' : base#envvar('LOCALAPPDATA'),
        \ })

    call base#pathset({ 
				\ 'db' : base#qw#catpath('home','db'),
        \ })

    call base#pathset({ 
        \ 'appdata_plg_base'  : base#qw#catpath('appdata','vim plg base'),
        \ 'appdata_plg_perlmy'  : base#qw#catpath('appdata','vim plg perlmy'),
        \ })

    call base#pathset({ 
        \ 'saved_urls'  : base#qw#catpath('appdata_plg_base','saved_urls'),
        \ })
		
		let evbin = base#file#catfile([ 
			\	base#path('appdata_local'), 'Apps', 'Evince-2.32.0.145', 'bin' ])
			
    if isdirectory(evbin)
      call base#pathset({  'evince_bin' : evbin })
    endif
		
    call base#pathset({ 
        \ 'progs'  : base#file#catfile([ base#path('hm'),'programs' ]),
        \ })
		
	let pc = base#pcname()
	if pc == 'APOPLAVSKIYNB'
		call base#initpaths#APOPLAVSKIYNB()
	elseif pc == 'RESTPC'
		call base#initpaths#RESTPC()
	endif
	
	call base#pathset({ 
      \ "repos_git" : base#file#catfile([ base#path('hm'), 'repos', 'git'  ]),
	  \ })
		
    call base#pathset({
        \   'pdfout'      : base#envvar('PDFOUT'),
        \   'htmlout'     : base#envvar('HTMLOUT'),
        \   'jsdocs'      : base#envvar('JSDOCS'),
        \   'htmldocs'    : base#envvar('HTMLDOCS',base#qw#catpath('repos_git','htmldocs')),
        \ })

    call base#pathset({
        \ 'vh_mdn_elem' : base#qw#catpath('plg','idephp doc html mdn_html_elements_reference'),
        \ })


    call base#pathset({
        \   'desktop'     : base#file#catfile([ hm, base#qw("Desktop") ]),
        \   'projs'       : projsdir,
        \   'perlmod'     : base#file#catfile([ base#path('repos_git'), base#qw("perlmod") ]),
        \   'projs_da'    : base#file#catfile([ hm, base#qw("repos git projs_da") ]),
        \   })

	    call base#initpaths#progs()
	    call base#initpaths#php()
	    call base#initpaths#perl()
	    call base#initpaths#docs()
	    call base#initpaths#data()

        "\  'projs_da'    : base#file#catfile([ base#qw("Z: ap projs_da") ]),

    "" remove / from the end of the directory
		call base#paths_nice()

    call base#pathlist()

  call base#echoprefixold()
endf


fun! base#init#cmds()
	call base#init#cmds_plg()

"""XmlPretty
	command! XmlPretty call base#xml#pretty()

"""CD
	command! -nargs=* -complete=custom,base#complete#CD      CD
		\	call base#CD(<f-args>) 

"""DIR
	command! -nargs=* -complete=custom,base#complete#DIR     DIR
		\	call base#DIR(<f-args>) 

"""MkDir
	command! -nargs=*  MkDir
		\	call base#mkdir#prompt(<f-args>) 

"""BaseSYS
	command! -nargs=* -complete=custom,base#complete#basesys BaseSYS
		\	call base#sys_split_output(<f-args>) 

"""BaseLog
	command! -nargs=* -complete=custom,base#complete#baselog BaseLog
		\	call base#log#cmd(<f-args>) 

"""ImageAct
	command! -nargs=*  -complete=custom,base#complete#imageact ImageAct 
		\	call base#image#act(<f-args>)

"""FIND
	command! -nargs=* -complete=custom,base#complete#FIND  FIND 
		\	call base#cmd#FIND(<f-args>) 

"""VH
	command! -nargs=* -range -complete=custom,base#complete#VH  VH
		\	call base#vh#act(<f-args>,<line1>,<line2>) 

"""ExeFileRun
	command! -nargs=*  -complete=custom,base#complete#exefileids FileRun
		\	call base#exefile#run_prompt(<f-args>)

"""ExeFileEcho
	command! -nargs=* -complete=custom,base#complete#exefileids FileEcho
		\	call base#exefile#echo(<f-args>)

"""FileView
	command! -nargs=* -complete=custom,base#complete#fileids
	    \   FileView call base#f#view(<f-args>) 

"""BaseAct
	command! -nargs=* -complete=custom,base#complete#BaseAct      BaseAct
		\	call base#act(<f-args>) 

"""BufAct
	command! -nargs=* -range -complete=custom,base#complete#BufAct      BufAct
		\	call base#buf#act(<line1>,<line2>,<f-args>) 

"""BaseVimFun
	command! -nargs=* -complete=custom,base#complete#hist#BaseVimFun BaseVimFun
		\	call base#vim#showfun(<f-args>)

"""BaseVimCom
	command! -nargs=* -complete=command BaseVimCom
		\	call base#vim#showcom(<f-args>)

"""BaseAppend
	command! -nargs=* -complete=custom,base#complete#BaseAppend BaseAppend
		\	call base#append(<f-args>)


"""LCOM
	command! -nargs=* -complete=custom,base#complete#vimcoms LCOM 
		\	call base#loadvimcom(<f-args>)
	
"""VCOM
	command! -nargs=* -complete=custom,base#complete#vimcoms VCOM 
		\	call base#viewvimcom(<f-args>)
	
"""LFUN
	command! -nargs=1 -complete=custom,base#complete#vimfuns LFUN 
		\	call base#loadvimfunc(<f-args>)
	
"""RFUN
	command! -nargs=1 -complete=custom,base#complete#vimfuns RFUN 
		\	call base#runvimfunc(<f-args>)
	
"""VFUN
	command! -nargs=1 -complete=custom,base#complete#vimfuns VFUN 
		\	call base#viewvimfunc(<f-args>)

"""PowerShell
	command! -nargs=* -complete=custom,base#complete#powershell PowerShell
		\	call base#powershell(<f-args>)

"""EnvCmd
	command! -nargs=* -complete=custom,base#complete#envcmd     EnvCmd
		\	call base#envcmd(<f-args>)

"""EnvEcho
	command! -nargs=* -complete=custom,base#complete#envecho   EnvEcho
		\	call base#env#echo(<f-args>)

"""GitCmd
	command! -nargs=* -complete=custom,base#complete#gitcmds GitCmd 
		\	call base#git(<f-args>)

"""GitSave
	command! -nargs=* -complete=custom,base#complete#gitcmds GitSave
		\	call base#git#save()


"""MenuReset
command!-nargs=* -complete=custom,base#complete#menus
	\	MenuReset call base#menu#add(<f-args>,{ 'action' : 'reset' })


"""MenuAdd
command! -nargs=* -complete=custom,base#complete#menus
	\	MenuAdd call base#menu#add(<f-args>,{ 'action' : 'add' })

command! -nargs=* -complete=custom,base#complete#menus
	\	MenuRemove call base#menu#remove(<f-args>)

"""GitUpdate
	command! -nargs=1 -complete=custom,base#complete#gitupdate GitUpdate
		\	call base#git#update(<f-args>)

	command! -nargs=1 -complete=custom,base#complete#sync Sync
		\	call base#sync#run(<f-args>)
	
"""INFO
	command! -nargs=* -complete=custom,base#complete#info    INFO
		\	call base#info(<f-args>)

"""OMNIFUNC
	command! -nargs=* -complete=custom,base#complete#omnioptions OMNIFUNC
  		\ call base#omni#selectcompletion(<f-args>)

"""OMNIFUNCADD
command! -nargs=* -complete=custom,base#complete#omnioptions
  \ OMNIFUNCADD call base#omni#selectcompletion(<f-args>,'add')
	
"""BaseVarUpdate
	command! -nargs=* -complete=custom,base#complete#varlist BaseVarUpdate 
		\	call base#var#update(<f-args>) 

"""OptEcho
	command! -nargs=* -complete=custom,base#complete#opts
	    \   OptEcho call base#opt#echo(<f-args>) 

"""OptSave
	command! -nargs=* -complete=custom,base#complete#opts
	    \   OptSave call base#opt#save(<f-args>) 

"""OptRestore
	command! -nargs=* -complete=custom,base#complete#opts
	    \   OptRestore call base#opt#restore(<f-args>) 

"""OptReset
	command! -nargs=* -complete=custom,base#complete#opts
	    \   OptReset call base#opt#reset(<f-args>) 
	
"""BaseVarEcho
	command! -nargs=* -complete=custom,base#complete#varlist
	    \   BaseVarEcho call base#varecho(<f-args>) 

"""BaseVarRemove
	command! -nargs=* -complete=custom,base#complete#varlist
	    \   BaseVarRemove call base#varremove(<f-args>) 

	command! -nargs=* -complete=custom,base#complete#varlist
	    \   BaseVarDump call base#var#dump_split(<f-args>) 


	command! -nargs=* -complete=custom,base#complete#CD
	    \   BasePathEcho call base#path#echo(<f-args>) 
	
"""BaseInit
	command! -nargs=* -complete=custom,base#complete#init
	    \   BaseInit call base#init(<f-args>) 

"""VimLinesExecute
	command! -nargs=* -range VimLinesExecute
	\	call base#vimlines#action('execute',<line1>,<line2>,<f-args>)
	
"""BaseDatView
	command! -nargs=* -complete=custom,base#complete#datlist
	    \   BaseDatView call base#viewdat(<f-args>) 

"""IDAT
	command! -nargs=* -complete=custom,base#complete#datlist
	    \   IDAT call base#idat#act(<f-args>) 
	
"""StatusLine
	command! -nargs=* -complete=custom,base#complete#statuslines
	    \   StatusLine call base#stl#set(<f-args>) 

"""TgSet
	command! -nargs=* -complete=custom,base#complete#tagids  TgSet
	    \   call base#tg#set(<f-args>) 

"""TgView
	command! -nargs=* -complete=custom,base#complete#tagids  TgView
	    \   call base#tg#view(<f-args>) 

"""TgUpdate
	command! -nargs=* -complete=custom,base#complete#tagids  TgUpdate 
		\	call base#tg#update(<f-args>) 

"""TgGo
	command! -nargs=* -complete=tag_listfiles  TgGo
		\	call base#tg#go(<f-args>) 

"""TgAdd
	command! -nargs=* -complete=custom,base#complete#tagids  TgAdd 
		\	call base#tg#add(<f-args>) 

"""BuffersList
	command! -nargs=*  BuffersList
		\	call base#buffers#list(<f-args>) 

"""BuffersWipeAll
	command! -nargs=*  BuffersWipeAll
		\	call base#buffers#wipeall(<f-args>)
	 

endfun

function! base#init#tagids ()
    let datafile = base#datafile('tagids')

    if !filereadable(datafile)
        call base#warn({ 
            \   "text": 'NO datafile for: tagids'
            \   })
        return 0
    endif

    let data = base#readdatfile({ 
        \   "file" : datafile ,
        \   "type" : 'list' ,
        \   })

    call base#varset('tagids',data)
	
endfunction

fun! base#init#sqlite(...)
	let ref = get(a:000,0,{})

	let reload = get(ref,'reload',0)
	let dbfile = base#dbfile()

	let home = base#envvar('home')
  call base#pathset({  
		\	'db' : base#file#catfile([ home, 'db' ]),
		\	})

	let dbfile = base#qw#catpath('db','vim_plg_base.db')
	call base#varset('plg_base_dbfile',dbfile)

	let done = base#varget('done_base_init_sqlite',0)
	if done && !reload
		return 
	endif

	let prf={ 'func' : 'base#init#sqlite','plugin' : 'base' }
	call base#log([
			\	'db initialization',
			\	],prf)

perl << eof
	use Vim::Perl qw(:funcs :vars);
	use Vim::Plg::Base;

	my $dbfile = VimVar('dbfile');

	my $prf = { prf => 'vim::plg::base' };
	our $plgbase = Vim::Plg::Base->new(
		sub_log        => sub { VimMsg([@_],$prf) },
		sub_warn       => sub { VimWarn([@_],$prf)  },
		sub_on_connect => sub {
			my ($dbh) = @_; 
			$Vim::Perl::DBH=$dbh; 
		},
		dbfile   => $dbfile,
	)->init;

eof

	call base#varset('done_base_init_sqlite',1)

endfunction

fun! base#init#au()
	let plgdir = base#plgdir()

	let datfiles = base#varget('datfiles',{})

 " exe 'augroup base_au_datfiles'
	"exe '   au!'
	"for [dat,datfile] in items(datfiles)
		"exe '   autocmd BufWritePost ' 
			"\	. datfile . ' call base#initvars()'
	"endfor
	"exe 'augroup end'

	au BufNewFile,BufWritePost,BufRead,BufWinEnter *.i.dat setf idat
	au BufRead,BufNewFile,BufWinEnter *.csv		set filetype=csv
	au BufRead,BufNewFile,BufWinEnter *.tsv		set filetype=tsv

	let plg  = base#path('plg')
	let plgu = base#file#win2unix(plg)

	"au_base_html
	exe 'au BufRead,BufNewFile,BufWinEnter '.plgu.'/base/autoload/base/html.vim call base#buf#onload() '	
	au BufWritePost *.i.dat call base#buf#au_write_post()

	"au BufRead,BufWinEnter * call base#buf#onload()
  au BufRead,BufNewFile,BufWinEnter * call base#buf#start() 
  au BufRead,BufNewFile,BufWinEnter * call base#buf#onload() 
     
endfun

function! base#init#vars (...)
    call base#echoprefix('(base#initvars)')

    call base#initvarsfromdat()

  	call base#varset('opts_keys',sort( keys( base#varget('opts',{}) )  ) )

    call base#varset('vim_funcs_user',
        \   base#fnamemodifysplitglob('funs','*.vim',':t:r'))

    call base#varset('vim_coms',
        \   base#fnamemodifysplitglob('coms','*.vim',':t:r'))

		call base#varlist()

    if $COMPUTERNAME == 'OPPC'
        let v='C:\Users\op\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe'
    		call base#varset('pdfviewer',v)
		elseif $COMPUTERNAME == 'APOPLAVSKIYNB'
        let v='C:\Users\apoplavskiy\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe'
    		call base#varset('pdfviewer',v)
    endif

		call base#echoprefixold()
endf    

fun! base#init#files(...)
    call base#echoprefix('(base#init#files)')

		call base#init#sqlite()

    let ref = {}
    if a:0 | let ref = a:1 | endif

	if	has('win32')
	    let evince =  base#file#catfile([ 
	      \ base#path('home'),
	      \ '\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe' 
	      \ ])
	else
		let evince='/usr/bin/evince'
    endif

    if filereadable(evince)
        call base#exefile#set({  'evince' : evince })
    endif

	let pc = base#pcname()
    if pc == 'APOPLAVSKIYNB'

      let cv  = base#file#catfile([ base#path('imagemagick'), 'convert.exe' ])
      let idn = base#file#catfile([ base#path('imagemagick'), 'identify.exe' ])

      call base#exefile#set({  'im_convert' : cv })
      call base#exefile#set({  'im_identify' : idn })

      "call base#txtfile#set({  'im_identify' : idn })

    endif

  call base#echoprefixold()
endf

function! base#init#plugins (...)

		call base#varsetfromdat('plugins','List')
		let plugins = base#varget('plugins',[])

		let dbfile = base#dbfile()
		call pymy#sqlite#dbfile(dbfile)

		call pymy#sqlite#query({
			\	'q'      : 'DELETE FROM plugins',
			\	})

		let ref = {
					\ "insert" : "INSERT OR IGNORE",
					\ "table"  : "plugins",
					\ "field"  : 'plugin',
					\ "list"   : plugins,
					\ }

		call pymy#sqlite#extend_with_list(ref)

		call base#init#plugins_all()

endf  

function! base#init#plugins_all (...)
		call pymy#sqlite#query({
			\	'q'      : 'delete from plugins_all',
			\	})
		
		call base#var#update('plugins_all')
		let plugins_all = base#varget('plugins_all',[])

		let ref = {
					\ "insert" : "INSERT OR IGNORE",
					\ "table"  : "plugins_all",
					\ "field"  : 'plugin',
					\ "list"   : plugins_all,
					\ }
		call pymy#sqlite#extend_with_list(ref)

endf
