
function! base#menu#remove(...)

	if a:0
    let menuopt=a:1
 else
    let menuopt=base#getfromchoosedialog({ 
        \ 'list'        : base#varget('menus',[]),
        \ 'startopt'    : 'projs',
        \ 'header'      : "Available menu options are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose menu option by number: ",
        \ })
 endif

 if menuopt == 'projs'
		call projs#menus#remove()

 elseif menuopt == 'sqlite'
		try 
			exe 'aunmenu &SQLITE.&COMMANDS'
			exe 'aunmenu &SQLITE'
		catch
 		endtry
 endif

endfunction

"Purpose: 
"		add menu 
"Usage: 
"	call base#menu#add(menuopt)
"	call base#menu#add(menuopt,{})
"	call base#menu#add(menuopt,{ 'action' : 'add' })
"	call base#menu#add(menuopt,{ 'action' : 'reset' })

function! base#menu#add(...)

 let opts = { 'action' : 'add' }

 if a:0
    let menuopt = get(a:000,0,'')
    if a:0 >= 2 
      call extend(opts,a:2)
    endif
 else
    let menuopt = base#getfromchoosedialog({ 
        \ 'list'        : base#varget('menus',[]),
        \ 'startopt'    : 'projs',
        \ 'header'      : "Available menu options are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose menu option by number: ",
        \ })
 endif

	if opts.action == 'reset'

		let menus_rm = []
		
		call extend(menus_rm,base#varget('menus_remove',[]))
		
		call extend(menus_rm,
		\   base#mapsub(base#varget('menus_toolbar_remove_items',[]),
		\   '^','ToolBar.','g'))
		
		call extend(menus_rm,keys(base#varget('allmenus',{}) ))
		
		let menus_rm = base#uniq(menus_rm)
		
		for m in menus_rm
				try
					exe 'aunmenu ' . m 
				catch
				endtry
		endfor

		call base#varhash#extend('isloaded',{ 'menus' : [ menuopt ] })

	elseif opts.action == 'add'
		let menus = base#varhash#get('isloaded','menus',[])
		call add(menus,menuopt)
		call base#varhash#extend('isloaded',{ 'menus' : menus })
	endif

"""_menuopt
 let menusbefore= [ 'menus', 'omni', 'buffers' ]
 if ! base#inlist(menuopt,menusbefore)
   for opt in menusbefore
     call base#menu#add(opt)
   endfor
 endif

"""menuopt_projs
 if menuopt == 'projs'
		call projs#menus#set()

    MenuAdd latex

"""menuopt_makefiles
 elseif menuopt == 'makefiles'

     let lev=15
     let makefiles=[]
     let makefiles=base#find({ 
                    \       'qw_dirids'  : 'projs',
                    \       'qw_exts'    : 'mk',
                    \    })
    
     call add(makefiles,base#catpath('projs','makefile'))

     call add(makefiles,base#qw#catpath('scripts','mk maketex.defs.mk'))
     call add(makefiles,base#qw#catpath('scripts','mk maketex.targets.mk'))
    
     for mf in makefiles
         let mfname = substitute(fnamemodify(mf,':p:t'),'\.','\\.','g')
         let mfdir  = fnamemodify(mf,':p:r')
            
         call base#menu#additem({
                        \   'item'  : '&MAKEFILES.&' . mfname,
                        \   'tab'       :   mfname,
                        \   'cmd'       :   'call base#fileopen("' . mf . '")',
                        \   'lev'       :   lev,
                        \   })
    
     endfor

"""menuopt_sqlite
 elseif menuopt == 'sqlite'
		let cmds = base#varget('opts_BaseAct',[])
		call filter(cmds,'len(matchlist(v:val,"^sqlite_"))')
		call map(cmds,'substitute(v:val,"^sqlite_","","g")')

		for cmd in cmds
         call base#menu#additem({
							\   'item'      : '&SQLITE.&COMMANDS.&' . cmd,
							\   'tab'       :  cmd,
							\   'cmd'       :  'BaseAct sqlite_'.cmd,
							\   })
		endfor


"""menuopt_dat
 elseif menuopt == 'dat'
   LFUN F_ViewDAT

   VarUpdate datfiles

   let datroots={
        \   'PERL' : [ 
                \   'hperl_targets',
                \   'perldoc2tex_topics',
                \   'perl_installed_modules',
                \   'perl_used_modules',
                \   'modules_all',
                \   ],
        \   }

   for [root,dats] in items(datroots)
     for dat in dats
       call base#menu#additem({
            \   'item'  : '&DAT.&' . root . '.&' . dat,
            \   'tab'   : dat,
            \   'cmd'   : 'call F_ViewDAT("' . dat . '")',
            \   })
     endfor
   endfor

"""menuopt_omni
 elseif menuopt == 'omni'

   for [id,menuitem] in items(base#varget('menus_omni',{}))
      call base#menu#additem(menuitem)
   endfor

"""menuopt_perl
 elseif menuopt == 'perl'
   LFUN Prl_module_sub_open

   call Prl_module_subs()

   if exists("g:moduleinfo.subnames")
       for sub in g:moduleinfo.subnames
         call base#menu#additem({
                \   'item'  :   '&PERL.&SUBS.&' . sub,
                \   'tab'   :   'sub',
                \   'cmd'   :   'call Prl_module_sub_open(' . "'" . sub . "'" ,
                \   })
       endfor
   endif

   let funcs=[
        \   'Prl_module_subs',
        \   'Prl_module_path',
        \   'Prl_module_pod',
        \   ]

   for fun in funcs
        call base#menu#additem({
            \   'item'  :   '&PERL.&VimFuncsEcho.&' . fun,
            \   'tab'   :   'sub',
            \   'cmd'   :   'echo ' . fun . '()',
            \   })
        call base#menu#additem({
            \   'item'  :   '&PERL.&VimFuncsCall.&' . fun,
            \   'tab'   :   'sub',
            \   'cmd'   :   'call ' . fun . '()',
            \   })
   endfor

"""menuopt_plaintex
 elseif menuopt == 'plaintex'
   let menus_add=[
      \ 'ToolBar.PlainTexRun',
      \ ]

   call base#menus#add(menus_add)

"""menuopt_buffers
 elseif menuopt == 'buffers'

     try
        silent exe 'aunmenu BUFFERS'
     catch
     endtry

	 let bref     = base#buffers#get()
	 
	 let bufs     = get(bref,'bufs',[])
	 let bufnums  = get(bref,'bufnums',[])
	 let buffiles = get(bref,'buffiles',[])

   let bufmenus={}


   for buf in bufs
		 let path = get(buf,'fullname','')
		 let num  = get(buf,'num',0)


     let mn  = ''
     let tab = ''

     let basename = fnamemodify(path,':p:t')
     let dirname  = fnamemodify(path,':p:h')
		 let ext      = fnamemodify(path,':p:e')

     let basename_escape = substitute(basename,'\.','\\.','g')
     let dirname_escape  = substitute(dirname,'\.','\\.','g')

     let mn = printf('&BUFFERS.&%s.&%s',ext,basename_escape)

     if len(mn)
        let menu={
           \   'item'  : join([num,mn],' '),
           \   'cmd'   : 'buffer ' . path,
           \   'tab'   : tab,
           \   }

        call extend(bufmenus,{ mn : menu })
     endif

   endfor

   for mn in sort(keys(bufmenus))
     let menu = bufmenus[mn]
     call base#menu#additem(menu)
   endfor

"""menuopt_menus
 elseif menuopt == 'menus'

   for mn in base#varget('menus',[])
      call base#menu#additem({
            \ 'item' : '&MENUS.&ADD.&' . mn,
            \ 'cmd'  : 'MenuAdd ' . mn,
            \ })
      call base#menu#additem({
            \ 'item' : '&MENUS.&RESET.&' . mn,
            \ 'cmd'  : 'MenuReset ' . mn,
            \ })
   endfor

"""menuopt_latex
 elseif menuopt == 'latex'

      for entry in base#varget('tex_insert_entries',[]) 
        	call base#menu#additem({
            \ 'item' : '&TEX.&INSERT.&' . entry,
            \ 'cmd'  : 'TEXINSERT ' . entry,
            \ })
      endfor

      let texinputs=base#find({
            \ 'qw_dirids'    : 'texinputs',
            \ 'qw_exts'      : 'tex',
            \ 'fnamemodify'  : ':p:t',
            \ })

      for id in texinputs

        let fname = substitute(id,'\.','\\.','g')
        let file  = base#catpath('texinputs',fname)

        call base#menu#additem({
              \ 'item' : '&TEX.&TEXINPUTS.&' . fname,
              \ 'cmd'  : 'call base#fileopen(' . "'" . file . "'" . ')',
              \ })
      endfor

      call base#menu#additem({
            \ 'item' : '&TEX.&RUN.&pdfTeX' ,
            \ 'cmd'  : 'PlainTexRun',
            \ })

 endif
 
endfunction

function! base#menu#additem (ref)

 let cmd  = 'anoremenu '
 let cmds = []

 let ref={
			 	\	'icon'    : '',
			 	\	'item'    : '',
			 	\	'cmd'     : '',
			 	\	'fullcmd' : '',
			 	\	'tab'     : '',
			 	\	'tmenu'   : '',
		 		\	}

 call extend(ref,a:ref)

 if len(ref.icon)
	 let iconfile = base#catpath('menuicons',ref.icon . '.png')
	 if filereadable(iconfile)
	 		let cmd.='icon=' . iconfile . ' '
	 else
		 	call base#warn({ 'text' : 'icon file not readable:' . iconfile })
	 endif
 endif

 if ! len(ref.item)
	 call base#warn({ 'text' : 'menu item not defined!' })
	 return
 else
	 let cmd.=ref.item . ' '
 endif

 if ref.tab
	 let cmd.='<Tab>' . ref.tab . ' '
 endif

 if ! len(ref.cmd)
	 if ! len(ref.fullcmd)
		 call base#warn('menu command not defined!')
		 return
	 else
		 let cmd = ref.fullcmd
 	 endif
 else
	 let cmd.=':' . ref.cmd . '<CR>'
 endif
 call add(cmds,cmd)

 if ref.tmenu
 		call add(cmds,'tmenu ' . ref.item . ' ' . ref.tmenu)
 endif

 for cmd in cmds
	try
		exe cmd
	catch 
		echo v:exception
		echo cmd
	endtry
 endfor

 let isloaded = base#varget('isloaded',{})
 let mni      = get(isloaded,'menuitems',[])

 call add(mni,ref.item)
 call extend(isloaded, { 'menuitems' : mni })

 call base#varset('isloaded',isloaded)

endfunction
 

 
function! base#menu#add_alphabet(ref)

 let ref=a:ref

 let lev=10

 for id in g:{ref.arr}
        let lett=toupper(matchstr(id,'^\zs\w\ze'))

	    call base#menu#additem({
				\	'item' 	: '&' . ref.name . '.&' . lett . '.&' . id,
	 			\	'cmd'	: ref.cmd . ' ' . id,
	 			\	'lev'	: lev,
	 			\	})

	    let lev+=10
 endfor

endfunction

