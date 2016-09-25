
fun! base#init#cmds()

"""CD
	command! -nargs=* -complete=custom,base#complete#CD      CD
		\	call base#CD(<f-args>) 

"""FileEcho
	command! -nargs=* -complete=custom,base#complete#fileids FileEcho
		\	call base#f#echo(<f-args>)

"""FileAdd
	command! -nargs=* -complete=custom,base#complete#fileadd
	    \   FileAdd call base#f#add(<f-args>) 

	command! -nargs=* -complete=custom,base#complete#hist#BaseVimFun BaseVimFun
		\	call base#vim#showfun(<f-args>)

	command! -nargs=* -complete=custom,base#complete#hist#BaseVimCom BaseVimCom
		\	call base#vim#showcom(<f-args>)

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


	command! -nargs=* -complete=custom,base#complete#CD
	    \   BasePathEcho call base#path#echo(<f-args>) 
	
"""BaseInit
	command! -nargs=* -complete=custom,base#complete#init
	    \   BaseInit call base#init(<f-args>) 
	
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

fun! base#init#au()

	let plgdir = base#plgdir()

	let datfiles = base#var('datfiles')

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

"au FileType * call base#statusline('neat')


  "LFUN F_OnLoad_perl
  "LFUN F_OnLoad_dat
  "LFUN F_OnLoad_vim
  "LFUN F_OnLoad_help
  "LFUN F_OnLoad_txt

  "LFUN SNI_Reload


  "augroup onload_perl
		"au!
		"autocmd BufRead      *.pm,*.pl,*.pod call F_OnLoad_perl('BufRead')
		"autocmd BufWinEnter  *.pm,*.pl,*.pod call F_OnLoad_perl('BufWinEnter')
		"autocmd BufNewFile   *.pm,*.pl,*.pod call F_OnLoad_perl('BufNewFile')
		"autocmd BufWritePost *.pm,*.pl,*.pod call F_OnLoad_perl('BufWritePost')
  "augroup end

  "augroup onload_all
		"au!
		"autocmd FileType  * call SNI_Reload()
  "augroup end

  "augroup onload_txt
		"au!
		"autocmd BufRead      *.txt call F_OnLoad_txt('BufRead')
		"autocmd BufWinEnter  *.txt call F_OnLoad_txt('BufWinEnter')
		"autocmd BufNewFile   *.txt call F_OnLoad_txt('BufNewFile')
		"autocmd BufWritePost *.txt call F_OnLoad_txt('BufWritePost')

  "augroup END
	
  "augroup onload_vim
		"au!
		"autocmd BufRead      *.vim call F_OnLoad_vim('BufRead')
		"autocmd BufWinEnter  *.vim call F_OnLoad_vim('BufWinEnter')
		"autocmd BufNewFile   *.vim call F_OnLoad_vim('BufNewFile')
		"autocmd BufWritePost *.vim call F_OnLoad_vim('BufWritePost')

  "augroup END

  "augroup onload_dat
		"au!
		"autocmd BufRead      *.dat call F_OnLoad_dat('BufRead')
		"autocmd BufWinEnter  *.dat call F_OnLoad_dat('BufWinEnter')
		"autocmd BufNewFile   *.dat call F_OnLoad_dat('BufNewFile')
		"autocmd BufWritePost *.dat call F_OnLoad_dat('BufWritePost')

  "augroup END

  "augroup op_vimconsole
	  "au!
	
	  "autocmd BufNewFile,BufRead zshrc set ft=sh
	
	  "autocmd BufNewFile,BufRead *.i.dat set ft=dat
	  "autocmd BufNewFile,BufRead *.dat set ft=dat
	  "autocmd BufNewFile,BufRead *.tex set ft=tex
	
	  "autocmd BufNewFile,BufRead *.data set ft=sql
	  "autocmd BufNewFile,BufRead *.db set ft=sql
	
	  "autocmd BufNewFile,BufRead makefile set makeprg=make | call F_CdP()
	  "autocmd BufNewFile,BufRead gitconfig set ft=gitconfig
		
	  "autocmd BufNewFile,BufRead,BufWinEnter $hm/wrk/traveltek/* 
        "\   RFUN TRV_OnLoad

	  "autocmd BufNewFile,BufRead,BufWinEnter /doc/perl/tex/makefile 
		  "\	compiler latex |
		  "\	set makeprg=make\ _hperl

  "augroup end


