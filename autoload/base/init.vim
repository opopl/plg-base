
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

