

function! base#menu#add(...)
 RFUN SubNameStart F_AddMenus

 LFUN F_FileOpen
 LFUN F_ListAdd
 LFUN F_MenuAddAlphabet
 LFUN F_MenuItemAdd
 LFUN F_MenusAdd
 LFUN F_ReadDatFile
 LFUN F_VarCheckExist
 LFUN F_VarUpdate
 LFUN F_EqualPaths
 LFUN F_map_sub
 LFUN F_uniq
 LFUN F_rmwh
 LFUN F_CatFile

 LCOM MenuAdd
 LCOM VarUpdate

 let vars=[
            \   'allmenus',
            \   'F_menus',
            \   ]

 call F_VarUpdate(vars)

 let opts={ 'action' : 'add' }

 if a:0
    let menuopt=a:1
    if a:0 >= 2 
      call extend(opts,a:2)
    endif
 else
    let menuopt=base#getfromchoosedialog({ 
        \ 'list'        : base#varget('menus',[]),
        \ 'startopt'    : 'projs',
        \ 'header'      : "Available menu options are: ",
        \ 'numcols'     : 1,
        \ 'bottom'      : "Choose menu option by number: ",
        \ })
 endif

 if opts.action == 'reset'

  let menus_rm=[]

  call extend(menus_rm,F_ReadDatFile('menus_remove'))

  call extend(menus_rm,
    \   F_map_sub(F_ReadDatFile('menus_toolbar_remove_items'),
    \   '^','ToolBar.','g'))

  call extend(menus_rm,keys(g:allmenus))

  let menus_rm=F_uniq(menus_rm)

  for m in menus_rm
    try
        exe 'aunmenu ' . m 
    catch
    endtry
  endfor

  let g:isloaded.menus=[ menuopt ] 

 elseif opts.action == 'add'
 	 call F_ListAdd('g:isloaded.menus',menuopt)

 endif

"""_menuopt
 let menusbefore= [ 'menus', 'omni', 'buffers' ]
 if ! base#inlist(menuopt,menusbefore)
   for opt in menusbefore
     call F_MenuAdd(opt)
   endfor
 endif

"""menuopt_projs
 if menuopt == 'projs'
    RFUN DC_Proj_SetMenus

    MenuAdd latex
    MenuAdd snippets

"""menuopt_makefiles
 elseif menuopt == 'makefiles'

     let lev=15
     let makefiles=[]
     let makefiles=F_find({ 
                    \       'path'  : 'projs',
                    \       'ext'   : 'mk',
                    \    })
    
     call add(makefiles,F_CatPath('projs','makefile'))
     call add(makefiles,F_CatFile('scripts','mk maketex.defs.mk'))
     call add(makefiles,F_CatFile('scripts','mk maketex.targets.mk'))
    
     for mf in makefiles
         let mfname=substitute(fnamemodify(mf,':p:t'),'\.','\\.','g')
         let mfdir=fnamemodify(mf,':p:r')
            
         call F_MenuItemAdd({
                        \   'item'  : '&MAKEFILES.&' . mfname,
                        \   'tab'       :   mfname,
                        \   'cmd'       :   'call F_FileOpen("' . mf . '")',
                        \   'lev'       :   lev,
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
       call F_MenuItemAdd({
            \   'item'  : '&DAT.&' . root . '.&' . dat,
            \   'tab'   : dat,
            \   'cmd'   : 'call F_ViewDAT("' . dat . '")',
            \   })
     endfor
   endfor

"""menuopt_omni
 elseif menuopt == 'omni'

   for [id,menuitem] in items(g:menus_omni)
      call F_MenuItemAdd(menuitem)
   endfor

"""menuopt_pod
 elseif menuopt == 'pod'
   let podmenuitems={
   		\	'PrlPodViewHtml' 	: {
            \   'item'  : '&POD.&ViewHtml',
            \   'tab'   : 'View\ Html',
            \   'cmd'   : 'PrlPodViewHtml',
   			\	},
   		\	'PrlPodViewTxt' 	: {
            \   'item'  : '&POD.&ViewTxt',
            \   'tab'   : 'View\ Txt',
            \   'cmd'   : 'PrlPodViewTxt',
   			\	},
   		\	}
   let podmenu=[
   		\	'PrlPodViewHtml',
   		\	'PrlPodViewTxt',
   		\	]

   for key in podmenu
	 let item=podmenuitems[key]
   	 call F_MenuItemAdd(item)
   endfor


"""menuopt_perl
 elseif menuopt == 'perl'
   LFUN Prl_module_sub_open

   call Prl_module_subs()

   if exists("g:moduleinfo.subnames")
       for sub in g:moduleinfo.subnames
         call F_MenuItemAdd({
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
        call F_MenuItemAdd({
            \   'item'  :   '&PERL.&VimFuncsEcho.&' . fun,
            \   'tab'   :   'sub',
            \   'cmd'   :   'echo ' . fun . '()',
            \   })
        call F_MenuItemAdd({
            \   'item'  :   '&PERL.&VimFuncsCall.&' . fun,
            \   'tab'   :   'sub',
            \   'cmd'   :   'call ' . fun . '()',
            \   })
   endfor


"""menuopt_perl_modules
 elseif menuopt == 'perl_modules'

   let menus_add=[
            \   'OMNI.perl_local_modules' ,
            \   'OMNI.perl_installed_modules' ,
            \   ]

   call F_MenusAdd(menus_add)

   let vars=[
    \   'perl_installed_modules',
    \   'perl_local_modules',
    \   'perl_used_modules',
    \   ]

   call F_VarCheckExist(vars)

"""_perl_modules_INSTALLED
    let lev=10
    let i=0
    for module in g:perl_installed_modules
      if i==0
        break
      endif
      
      let lett=toupper(matchstr(module,'^\zs\w\ze'))

      let mparts=
            \   matchstr(module,'^\zs\w\+\ze::') . '.&' . 
            \   matchstr(module,'^\w\+::\zs.*\ze$')

      let menu={
            \   'item'  : '&INSTALLED_MODS' . '.&' . lett . '.&' . mparts,
            \   'cmd'   : 'PMODI ' . module,
            \   'lev'   :    lev,
            \   }

      "call F_MenuItemAdd(menu)

            let lev+=10
    endfor

"""_perl_modules_ready


"""_perl_modules_LOCAL
     let topics=filter(F_ReadDatFile('datfiles'),
        \   "v:val =~ '^perl_modules_'")
     call map(topics,"matchstr(v:val,'^perl_modules_\\zs.*\\ze$')")

     let lev=10
     for module in g:perl_local_modules
         for topic in topics
             let menu={}

             if base#inlist(module,F_ReadDatFile('perl_modules_' . topic ))
                 let menu={
                    \   'item'  : '&LOCAL_MODS' . '.&' . topic . '.&' . module,
                    \   'cmd'   : 'PMOD ' . module,
                    \   'lev'   :    lev,
                    \   }
             endif

             if len(menu)
                 call F_MenuItemAdd(menu)
             endif
         endfor

         let lev+=1
     endfor

"""_perl_modules_USED
   call F_MenuAddAlphabet({
            \   'name'  : 'USED_MODS',
            \   'arr'   : 'perl_used_modules',
            \   'cmd'   : 'PMODI',
            \   })
  
"""menuopt_snippets
 elseif menuopt == 'snippets'

"""menuopt_plaintex
 elseif menuopt == 'plaintex'
   let menus_add=[
      \ 'ToolBar.PlainTexRun',
      \ ]

   call F_MenusAdd(menus_add)

"""menuopt_buffers
 elseif menuopt == 'buffers'
   LFUN F_BuffersGet

     try
        silent exe 'aunmenu BUFFERS'
     catch
     endtry

   call F_BuffersGet()
   let bufmenus={}

   for buf in g:bufs
     let path=buf[-3]
     let mn=''
     let tab=''

     let path=matchstr(path,'^"\zs.*\ze"$')

     let basename=fnamemodify(path,':p:t')
     let dirname=fnamemodify(path,':p:h')

     let basename_escape=substitute(basename,'\.','\\.','g')
     let dirname_escape=substitute(dirname,'\.','\\.','g')

     if path =~ '\.pm$'
        let module=
            \   F_sss("get_perl_package_name.pl --ifile " . path)

        let mn='&BUFFERS.&PERL_MODULES.&' . module
       
     elseif path =~ '_fun_/\w\+\.vim$'
        let vimfun=matchstr(path,'_fun_/\zs\w\+\ze\.vim$')

        let mn='&BUFFERS.&VIM_FUNS.&' . vimfun

     elseif path =~ '_coms_/\w\+\.vim$'
        let vimcom=matchstr(path,'_coms_/\zs\w\+\ze\.vim$')

        let mn='&BUFFERS.&VIM_COMS.&' . vimcom

     elseif path =~ '\.i\.dat$' 

       let dat=matchstr(basename,'^\zs.*\ze\.i\.dat$')
       
       if F_EqualPaths(dirname,g:paths['mkvimrc'])
            let mn='&BUFFERS.&DAT_VIM.&' . dat
       else
            let mn='&BUFFERS.&DAT.&' . dat
       endif

     elseif path =~ '\.tex$' 

       if F_EqualPaths(dirname,g:paths['projs'])
            
            let mn='&BUFFERS.&TEX.&PROJS.&' . basename_escape

       endif

     else 
            let width=70
            let sepwidth=width-strlen(basename_escape)-strlen(dirname_escape)

            let mn='&BUFFERS.&OTHER.&' . basename_escape 
            let tab=dirname_escape

     endif

     if len(mn)
        let menu={
           \   'item'  :  mn,
           \   'cmd'   : 'buffer ' . path,
           \   'tab'   : tab,
           \   }

        call extend(bufmenus,{ mn : menu })
     endif

   endfor
   """ end loop over g:bufs

   for mn in sort(keys(bufmenus))
     let menu=bufmenus[mn]
     call F_MenuItemAdd(menu)
   endfor

"""menuopt_paps
 elseif menuopt == 'paps'
   LFUN LOP

   call F_VarCheckExist('PAP_texpkeys')

   call F_MenuAddAlphabet({
            \   'name'  : 'TEXPAPS',
            \   'arr'   : 'PAP_texpkeys',
            \   'cmd'   : 'LOP',
            \   })


   call F_MenuItemAdd({
            \ 'item' : '&ToolBar.&PMAKE_LATEX',
            \ 'icon' : 'PMAKE_latex',
            \ 'cmd'  : 'PMAKE latex',
            \ 'tmenu'  : 'Run LaTeX',
            \ })

   call F_MenuItemAdd({
            \ 'item' : '&ToolBar.&PMAKE_TEX_GENERATE',
            \ 'icon' : 'PMAKE_tex_generate',
            \ 'cmd'  : 'PMAKE tex_generate',
            \ 'tmenu'  : 'Generate TeX files',
            \ })

"""menuopt_menus
 elseif menuopt == 'menus'
   call F_VarCheckExist('F_menus')

   for mn in g:F_menus
      call F_MenuItemAdd({
            \ 'item' : '&MENUS.&ADD.&' . mn,
            \ 'cmd'  : 'MenuAdd ' . mn,
            \ })
      call F_MenuItemAdd({
            \ 'item' : '&MENUS.&RESET.&' . mn,
            \ 'cmd'  : 'MenuReset ' . mn,
            \ })
   endfor

"""menuopt_latex
 elseif menuopt == 'latex'

      for entry in g:TEX_InsertEntries
        call F_MenuItemAdd({
            \ 'item' : '&TEX.&INSERT.&' . entry,
            \ 'cmd'  : 'TEXINSERT ' . entry,
            \ })
      endfor

      let texinputs=F_find({
            \ 'path' : 'texinputs',
            \ 'ext'  : 'tex',
            \ 'fnamemodify'  : ':p:t',
            \ })

      for id in texinputs

        let fname=substitute(id,'\.','\\.','g')
        let file=F_CatPath('texinputs',fname)
        call F_MenuItemAdd({
              \ 'item' : '&TEX.&TEXINPUTS.&' . fname,
              \ 'cmd'  : 'call F_FileOpen(' . "'" . file . "'" . ')',
              \ })
      endfor

      call F_MenuItemAdd({
            \ 'item' : '&TEX.&RUN.&pdfTeX' ,
            \ 'cmd'  : 'PlainTexRun',
            \ })

 endif
 
 RFUN SubNameEnd 
endfunction
 
