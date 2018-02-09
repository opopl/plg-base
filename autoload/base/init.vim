
fun! base#init#cmds_plg ()

"""PlgAct
	command! -nargs=* -complete=custom,base#complete#plg PlgAct
		\	call base#plg#act(<f-args>) 

"""PlgView
	command! -nargs=* -complete=custom,base#complete#plg PlgView 
		\	call base#plg#view(<f-args>) 

"""PlgHelp
	command! -nargs=* -complete=custom,base#complete#plg PlgHelp
		\	call base#plg#help(<f-args>) 

"""PlgGrep
	command! -nargs=* -complete=custom,base#complete#plg PlgGrep
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

		let plg = base#file#catfile([  $VIMRUNTIME, 'plg'  ])

    call base#pathset({  'plg' : plg })

		let dir = base#file#catfile([  $VIMRUNTIME, 'plg', 'base'  ])
		
		call base#varset('plgdir',dir)
		call base#datadir( base#file#catfile([ dir, 'data' ]) )

    let ref = {}
    if a:0 | let ref = a:1 | endif

    let do_echo=0
    if exists("g:base_echo_init") && g:base_echo_init
      let do_echo = 1
    endif
 
"""define_paths

    let anew = 0
    if ! exists("s:paths") 
        let anew = 1 
    else
        if get(ref,'anew',0) 
            let anew = 1 
        endif
    endif
        
    if anew
    if do_echo
          call base#echo({ 
              \   "text" : 'Settings paths anew...' 
              \   })
    endif
        let s:paths={}
    endif

    let confdir   = base#envvar('CONFDIR')
    let vrt       = base#envvar('VIMRUNTIME')
    let hm        = base#envvar('hm')
    let mrc       = base#envvar('MYVIMRC')
    let projsdir  = base#envvar('PROJSDIR')
    let pf        = base#envvar('PROGRAMFILES')

    let home      = base#envvar('USERPROFILE')

    let pc = base#envvar('COMPUTERNAME')

    let evbin = home.'\AppData\Local\Apps\Evince-2.32.0.145\bin'
    if isdirectory(evbin)
      call base#pathset({  'evince_bin' : evbin })
    endif

    call base#pathset({ 
        \ 'home'    : home ,
        \ 'hm'      : hm ,
        \ 'pf'      : pf ,
        \ 'conf'    : confdir ,
        \ 'vrt'     : vrt,
        \ 'vim'     : base#envvar('VIM'),
        \ 'src_vim' : base#envvar('SRC_VIM'),
        \ 'texdocs' : projsdir,
        \ 'p'       : base#envvar('TexPapersRoot'),
        \ 'phd_p'   : base#envvar('TexPapersRoot'),
        \ 'include_win_sdk'   : base#envvar('INCLUDE_WIN_SDK'),
        \   })

    call base#pathset({
        \   'progs'  : base#file#catfile([ base#path('hm'),'programs' ]),
        \ })

		let pc = $COMPUTERNAME
    if pc == 'APOPLAVSKIYNB'
        call base#initpaths#apoplavskiynb()
		elseif pc == 'RESTPC'
        call base#initpaths#restpc()
    endif

    let mkvimrc  = base#file#catfile([ base#path('conf'), 'mk', 'vimrc' ])
    let mkbashrc = base#file#catfile([ base#path('conf'), 'mk', 'bashrc' ])

    call base#pathset({
        \   'pdfout'      : base#envvar('PDFOUT'),
        \   'htmlout'     : base#envvar('HTMLOUT'),
        \   'jsdocs'      : base#envvar('JSDOCS'),
        \ })

    call base#pathset({
        \   'jq_course_local'  : base#file#catfile([ base#path('open_server'),'domains', 'jq-course.local' ]),
        \   'quote_service_local'  : base#file#catfile([ base#path('open_server'),'domains', 'quote-service.local' ]),
        \ })

    call base#pathset({
        \   'ap_local'    : base#file#catfile([ base#path('open_server'),'domains', 'ap.local' ]),
        \   'inews_local' : base#file#catfile([ base#path('open_server'),'domains', 'inews.local' ]),
        \ })

    call base#pathset({
        \ 'vh_mdn_elem' : base#qw#catpath('plg','idephp doc html mdn_html_elements_reference'),
        \ })


    call base#pathset({
        \   'desktop'     : base#file#catfile([ hm, base#qw("Desktop") ]),
        \   'mkvimrc'     : mkvimrc,
        \   'mkbashrc'    : mkbashrc,
        \   'coms'        : base#file#catfile([ mkvimrc, '_coms_' ]) ,
        \   'funs'        : base#file#catfile([ mkvimrc, '_fun_' ]) ,
        \   'projs'       : projsdir,
        \   'perlmod'     : base#file#catfile([ hm, base#qw("repos git perlmod") ]),
        \   'perlscripts' : base#file#catfile([ hm, base#qw("scripts perl") ]),
        \   'scripts'     : base#file#catfile([ hm, base#qw("scripts") ]),
        \   'projs_my'    : base#file#catfile([ hm, base#qw("repos git projs_my") ]),
        \   'projs_da'    : base#file#catfile([ hm, base#qw("repos git projs_da") ]),
        \   })

        "\  'projs_da'    : base#file#catfile([ base#qw("Z: ap projs_da") ]),

    "" remove / from the end of the directory
    for k in keys(s:paths)
       let s:paths[k]=substitute(s:paths[k],'\/\s*$','','g')
    endfor


    if exists("g:dirs")
       call extend(s:paths,g:dirs)
    endif
    let g:dirs = s:paths

    let pathlist = sort(keys(s:paths))
    call base#varset('pathlist',pathlist)

  if do_echo
    echo '--- base#initpaths ( paths initialization ) --- '
    echo 'Have set the value of g:dirs'
    echo 'Have set the value of base variable "pathlist" (check it via BaseVarEcho)'
    echo '--------------------------------------------------- '
  endif

  call base#echoprefixold()

endf


fun! base#init#cmds()
	call base#init#cmds_plg()

"""XmlPretty
	command! XmlPretty call base#xml#pretty()

"""CD
	command! -nargs=* -complete=custom,base#complete#CD      CD
		\	call base#CD(<f-args>) 

"""MkDir
	command! -nargs=*  MkDir
		\	call base#mkdir#prompt(<f-args>) 

"""BaseSYS
	command! -nargs=* -complete=custom,base#complete#basesys BaseSYS
		\	call base#sys_split_output(<f-args>) 

"""ImageAct
	command! -nargs=*  -complete=custom,base#complete#imageact ImageAct 
		\	call base#image#act(<f-args>)

"""FIND
	command! -nargs=* -complete=custom,base#complete#FIND  FIND 
		\	call base#cmd#FIND(<f-args>) 

"""FileRun
	command! -nargs=*  -complete=custom,base#complete#fileids FileRun
		\	call base#f#run_prompt(<f-args>)

"""FileEcho
	command! -nargs=* -complete=custom,base#complete#fileids FileEcho
		\	call base#f#echo(<f-args>)

"""FileAdd
	command! -nargs=* -complete=custom,base#complete#fileadd
	    \   FileAdd call base#f#add(<f-args>) 

"""FileView
	command! -nargs=* -complete=custom,base#complete#fileids
	    \   FileView call base#f#view(<f-args>) 

"""BaseAct
	command! -nargs=* -complete=custom,base#complete#BaseAct      BaseAct
		\	call base#act(<f-args>) 

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

"""TgAdd
	command! -nargs=* -complete=custom,base#complete#tagids  TgAdd 
		\	call base#tg#add(<f-args>) 

"""BuffersList
	command! -nargs=*  BuffersList
		\	call base#buffers#list(<f-args>) 

"""BuffersWipeAll
	command! -nargs=*  BuffersWipeAll
		\	call base#buffers#wipeall(<f-args>)

"""PP
	command! -nargs=* -complete=custom,base#complete#paplist PP
		\	call base#pap#import(<f-args>)
	 

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

fun! base#init#au()
	let plgdir = base#plgdir()

	let datfiles = base#varget('datfiles',{})

	exe 'augroup base_au_datfiles'
	exe '   au!'
	for [dat,datfile] in items(datfiles)
		exe '   autocmd BufWritePost ' 
			\	. datfile . ' call base#initvars()'
	endfor
	exe 'augroup end'

	au BufWritePost,BufRead,BufWinEnter *.i.dat setf conf
	au BufRead,BufWinEnter * call base#buf#onload()
  au FileType  * call base#buf#start() 
     
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
		elseif $COMPUTERNAME == 'apoplavskiynb'
        let v='C:\Users\apoplavskiy\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe'
    		call base#varset('pdfviewer',v)
    endif

		let plugins_all = base#find({ 
			\	"dirids"    : ['plg'],
			\	"cwd"       : 1,
			\	"relpath"   : 1,
			\	"subdirs"   : 0,
			\	"dirs_only" : 1,
			\	})
		call filter(plugins_all,'v:val !~ "^.git"')
    call base#varset('plugins_all',plugins_all)

    call base#echoprefixold()
endf    

fun! base#init#files(...)
    call base#echoprefix('(base#initfiles)')

    let ref = {}
    if a:0 | let ref = a:1 | endif

    let anew = 0
    if ! exists("s:files") 
        let anew = 1 
    else
        if get(ref,'anew',0) 
            let anew = 1 
        endif
    endif
        
    if anew
        call base#echo({ 
            \   "text" : 'Settings "files" hash anew...',
            \   })
        let s:files={}
    endif

    let evince =  base#file#catfile([ 
      \ base#path('home'),
      \ '\AppData\Local\Apps\Evince-2.32.0.145\bin\evince.exe' 
      \ ])

    if filereadable(evince)
        call base#f#set({  'evince' : evince })
    endif

    if $COMPUTERNAME == 'APOPLAVSKIYNB'

      let cv  = base#file#catfile([ base#path('imagemagick'), 'convert.exe' ])
      let idn = base#file#catfile([ base#path('imagemagick'), 'identify.exe' ])

      call base#f#set({  'im_convert' : cv })
      call base#f#set({  'im_identify' : idn })

    endif

  let exefiles={}
  for fileid in base#varget('exefileids',[])
    let  ok = base#sys({ 
			\ "cmds"        : [ 'where '.fileid ],
			\ "skip_errors" : 1,
			\ })

    if ok
        let found =  base#varget('sysout',[])
        let add={}
        for f in  found
            if filereadable(f)
                let add[f]=1
            endif
        endfor
        let k = keys(add)
        if len(k)
          call extend(exefiles,{ fileid : k } )
        endif
    endif

  endfor

  call base#f#set(exefiles)

  call base#echoprefixold()
endf

function! base#init#plugins (...)

    call base#varsetfromdat('plugins','List')

    if exists('g:plugins') | unlet g:plugins | endif
    let g:plugins=base#varget('plugins',[])

  if exists("g:base_echo_init") && g:base_echo_init
    echo '--- base#initplugins ( plugins initialization ) --- '
    echo 'Have set the value of g:plugins'
    echo 'Have set the value of base variable "plugins" (check it via BaseVarEcho plugins)'
    echo '--------------------------------------------------- '
  endif

endf  


