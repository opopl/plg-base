

fun! base#init#cmds()

	command! -nargs=* -complete=custom,base#complete#vimcoms 
		\ LCOM call base#loadvimcom(<f-args>)
	
	command! -nargs=* -complete=custom,base#complete#vimcoms 
		\ VCOM call base#viewvimcom(<f-args>)
	
	command! -nargs=1 -complete=custom,base#complete#vimfuns LFUN 
		\	call base#loadvimfunc(<f-args>)
	
	command! -nargs=1 -complete=custom,base#complete#vimfuns RFUN 
		\	call base#runvimfunc(<f-args>)
	
	command! -nargs=1 -complete=custom,base#complete#vimfuns VFUN 
		\	call base#viewvimfunc(<f-args>)
	
	command! -nargs=* -complete=custom,base#complete#info
	    \   INFO call base#info(<f-args>)
	   
	"command! -nargs=* -complete=custom,base#complete#datlist VDAT 
		"\	call base#viewdat(<f-args>) 
	
	command! -nargs=* -complete=custom,base#complete#varlist
	    \   BaseVarUpdate call base#varupdate(<f-args>) 
	
	command! -nargs=* -complete=custom,base#complete#varlist
	    \   BaseVarEcho call base#varecho(<f-args>) 
	
	command! -nargs=* 
	    \   BaseInit call base#init() 
	
	command! -nargs=* -complete=custom,base#complete#datlist
	    \   BaseDatView call base#viewdat(<f-args>) 
	
	command! -nargs=* -complete=custom,base#complete#statuslines
	    \   StatusLine call base#stl#set(<f-args>) 
	 

endfun


fun! base#init#au()

	"au FileType * call ap#stl()
    "au FileType * call ap#tags#set()

    "au FileType * call base#statusline('neat')

	"au BufWritePost,BufRead,BufWinEnter *.tex setf tex

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

 
endfun
