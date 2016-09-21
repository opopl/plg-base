 
"""base_datupdate
fun! base#old#datupdate(...)

 call base#varcheckexist("datfiles")

 if a:0
    let dat=a:1
 else
    let dat=base#getfromchoosedialog({ 
	       \ 'list'        : sort(keys(s:datfiles)),
	       \ 'startopt'    : 'datfiles',
	       \ 'header'      : "Available datfiles are: ",
	       \ 'numcols'     : 1,
	       \ 'bottom'      : "Choose datfile by number: ",
	       \ })
 endif

 if ! exists("s:datfiles[dat]")
   return
 endif

 let datfile=get(s:datfiles,dat)

 let lines=[]

"""datupdate_ctags_mkvimrc
 if dat == 'ctags_mkvimrc'
   let ids=[ 'mkvimrc', 'vimcom', 'vimfun' ]
   for id in ids
     call extend(lines,base#splitglob(id,'*.vim'))
   endfor

   for subdir in [ 'plugin', 'autoload', 'ftplugin', 'syntax' ]
        call extend(lines,split(globpath(&rtp,subdir . '/*.vim'),"\n"))
   endfor

"""datupdate_list_tex_papers
 elseif dat == 'list_tex_papers'

     call extend(lines,
        \ base#uniq(map(base#fnamemodifysplitglob('p','p.*.tex',':p:t:r'),
        \   "matchstr(v:val,'^p\\.\\zs\\w\\+\\ze')")))

"""datupdate_perl_installed_modules
 elseif dat == 'perl_installed_modules'
   call extend(lines,base#splitsystem('pmi ^' ) )

"""datupdate_perl_used_modules
 elseif dat == 'perl_used_modules'
   call extend(lines,base#splitsystem('pmi --searchdirs ' 
    \   . base#catpath('traveltek_modules','') . ' ^ready::ODTDMS::' ))

"""datupdate_perl_local_modules
 elseif dat == 'perl_local_modules'
   call extend(lines,base#splitsystem('pmi --searchdirs ' . $PERLMODDIR . '/lib ^' ))

 elseif dat == ''
   " code
 endif

 call writefile(lines,datfile)

endfun

"""base_old_varupdate
function! base#old#varupdate (ref)

 LFUN VH_linesTOC

 """ used for : DC_Proj_SecNames 
 LFUN DC_Proj_GenSecDat

 if type(a:ref) == type('')
   let varname=a:ref
   
 elseif type(a:ref) == type([])
   let vars=a:ref
   for varname in vars
     call base#old#varupdate(varname)
   endfor

   return
   
 endif

 let varname=substitute(varname,'^\(g:\)\+','','g')

 if exists(varname) 
   exe 'unlet g:' . varname
 endif

"""PAP_texpkeys
     if varname == 'PAP_texpkeys'
        let g:PAP_texpkeys=base#readdatfile('list_tex_papers')

   elseif varname == 'PAP_LOF_files'

        let g:{varname} = base#fnamemodifysplitglob('p','*.lof',':p:t:r')

     elseif varname == 'PAP_bibfiles'

        let g:{varname}={
              \ 'repdoc'  : base#catpath('p','repdoc.bib'),
              \ 'wchfdoc' : base#catpath('cit','wchfdoc.bib'),
            \}

"""PAP_bibkeys
     elseif varname == 'PAP_bibkeys'
        let g:PAP_bibkeys=base#readdatfile('list_bibkeys')

     elseif varname == 'TXT_InsertCmds'

        let g:{varname}={}
        for ft in [ 'vim', 'perl', 'tex', 'html' ]
            let g:{varname}[ft]=base#readdatfile(varname . '_' . ft)
        endfor

"""varupdate_pkey
     elseif varname == 'pkey'

       if !exists('g:' . varname)
            let g:{varname}=input('Paper name:','',
                \   'custom,PAP_CompleteTexPapers')
            call base#echoredraw('Paper key set: ' . g:pkey )
       endif


"""varupdate_files
     elseif varname == 'files'
        RFUN F_SetFiles

"""varupdate_paths
     elseif base#inlist(varname, [ 'paths', 'paths_list' ])
        call base#initpaths() 

     elseif varname == 'modelines'
        call base#varreset(varname,base#readdictDat(varname))

     elseif varname == 'TEX_StyFiles'

         let g:{varname}={
            \ 'my.sty': 'p',
            \}

     elseif varname == 'TEX_TexDefsAdded'

       let g:{varname}=[
          \ 'pmyyq',
          \ ]

"""VimSnips
     elseif varname == 'VimSnips'
       let g:{varname}=base#findunix({ 
            \   'path'          : 'vimsnips',
            \   'ext'           : 'vim',
            \   'fnamemodify'   : ':p:t:r',
            \   })


"""pdf_perldoc
     elseif varname == 'pdf_perldoc'
       let g:{varname}=base#findunix({
                \   'dir'           : s:paths['pdfout'] . '/perldoc',
                \   'ext'           : 'pdf',
                \   'fnamemodify'   : ':p:t:r',
                \   })

"""F_Bushes
     elseif varname == 'F_Bushes'
        let g:F_Bushes=[]

        call extend(g:F_Bushes,base#fnamemodifysplitglob('mkbashrc','*.bash',':t'))
        call extend(g:F_Bushes,base#fnamemodifysplitglob('mkbashrc','*.sh',':t'))

     elseif varname == 'SIMPLE_MakeSteps'

    let g:{varname}=[
          \  'tex_run' ,
          \  'tex_generate',
          \ ]

  elseif varname == 'LASU_IgnoreUnmatched'
      let g:{varname}= 1

  elseif varname == 'LASU_ShowallLines'
      let g:{varname}= 0

    elseif varname == 'rootlatexfile'
        let g:{varname}=''
        if &ft == 'tex'
              let g:{varname}= expand('%:p')
        endif

      elseif varname == 'roottexfile'
        let g:{varname}=''
        if &ft == 'plaintex'
          let g:{varname}= expand('%:p')
        endif

    elseif varname == 'PAP_DocStyles'

    let fcmd="find " 
      \ . base#catpath('p','docstyles') 
      \ . " -mindepth 1 -type d | perl -n -MFile::Basename -e 'print basename(\$_)'"

    let g:{varname}=split(system(fcmd),"\n")

    elseif varname == 'PAP_pkey'

    call base#varcheckexist([ 'RE' ])
 
      " g:PAP_pkey  - paper key, e.g. HT92
       let g:{varname}=substitute(g:PAP_papername,g:RE['PAP_paperpat'],'\1',"g")

    elseif varname == 'PAP_psec'

    call base#varcheckexist([ 'RE' ])

    " g:PAP_psec  - name of tex piece e.g. figs
    let g:{varname}=substitute(g:PAP_papername,g:RE['PAP_paperpat'],'\2',"g")
    let g:{varname}=substitute(g:{varname},'\.$','',"g")

    elseif varname == 'PAP_CurrentSection'

    call base#old#varupdate([ 'PAP_psec' ])

      let g:{varname}=substitute(g:PAP_psec,'^sec\.\(.*\)\.i','\1','g')

    elseif varname == 'PAP_listvars'

        LCOM CD
      
      CD p

      if ( !exists("g:PAP_listvars") || exists("g:PAP_FlagSetupRedo") )
        let g:PAP_listvars=split(system(  "mktex.pl --listvars | sort " ),"\n") 
    
        for var in g:PAP_listvars 
          let value=system(  "mktex.pl --var " . var )
          let value=substitute(value,"\n",'','')
          exe 'let g:PAP_' . var . '=' . "'" . value . "'"
        endfor
      endif

    elseif varname == 'PAP_PdfGen'
      let g:{varname}=base#findunix({ 
            \   'dir' : s:paths['p'] . '/out',
            \   'ext' : 'pdf',
            \   'relpath' : 1,
            \   'fnamemodify' : ':p:r',
            \   })

    elseif varname == 'PAP_PdfPapers'

        call base#mapsub()
        call base#basenamesplitglob()

      let g:PAP_PdfPapers=base#mapsub(base#basenamesplitglob('pdfpaps','*.pdf'),'\.pdf$','','g')

    elseif varname == 'DC_Proj_Files'

     let g:{varname} = base#splitglob('projs',g:proj . ".*.tex")
    
     call add(g:{varname},base#catpath('projs', g:proj . '.tex'))

"""comment_char
     elseif varname == 'comment_char'
             call base#old#varupdate('comment_chars')

             let g:{varname}= index(keys(g:comment_chars),&ft) < 0 ? '#' : 
                        \   g:comment_chars[&ft]

     elseif varname == 'comment_chars'
             let g:{varname}={
                    \   'tex' : '%',
                    \   'perl' : '#',
                    \   'vim' : '"',
                    \   }

"""varupdate_DC_Proj_Name
     elseif varname == 'DC_Proj_Name'
       call base#varcheckexist('proj')

       let g:{varname}=g:proj

     elseif varname == 'DC_PrjTexOutDir'
       "let g:{varname}=$hm . '/texbuilds/projs/'
       call base#varcheckexist('paths')
       let g:{varname}=s:paths['projs']

     elseif varname == 'DC_PrjTexMode'
       let g:{varname}='nonstopmode'

"""proj
     elseif varname == 'proj'
       LFUN DC_CompleteProjs

       let g:proj=input('Select project:','','custom,DC_CompleteProjs')

"""DC_Proj_SecNamesBase
     elseif varname == 'DC_Proj_SecNamesBase'
        call base#setglobalvarfromdat(varname)

"""DC_Proj_SecNames
     elseif varname == 'DC_Proj_SecNames'
       call base#varcheckexist([ 
              \ 'DC_Proj_SecNamesBase',
              \ 'DC_Proj_SecDatFile',
              \  ])

       let g:{varname}=base#rmendssplitglob('texdocs',g:proj . ".*.tex")

       call filter(g:{varname},"! base#inlist(v:val,g:DC_Proj_SecNamesBase)")

       call writefile(g:DC_Proj_SecNames,g:DC_Proj_SecDatFile)

       call base#uniq(varname)

     elseif varname == 'DC_Proj_SecDatFile'
       let g:{varname}=base#catpath('projs',g:proj . '.secs.i.dat')

     elseif varname == 'DC_Proj_SecOrderFile'
       let g:{varname}=base#catpath('projs',g:proj . '.secorder.i.dat')

       "call DC_Proj_GenSecDat()
       "
     elseif varname == 'OMNI_COMP_ARRAYS'
        let g:{varname}=base#readdictDat('OMNI_COMP_ARRAYS')

     elseif varname == 'OMNI_CompOptions_List'
        call base#old#varupdate('OMNI_COMP_ARRAYS')

    let comps=[]
    
    call extend(comps,keys(g:OMNI_COMP_ARRAYS))
    call add(comps,'_smart_tex')
    
    let g:OMNI_CompOptions_List=sort(comps)

"""PAP_allowed_psecs
     elseif varname == 'PAP_allowed_psecs'
        call base#setglobalvarfromdat(varname)

     elseif varname == 'IMOD_opts'
       LFUN F_opts_to_str

      " Install selected module
        let g:{varname}=F_opts_to_str({
          \ 'rbi_force'             : 1,
          \ 'rbi_discard_loaddat'   : 1,
          \} )

     elseif varname == 'IMODS_opts'
       LFUN F_opts_to_str

        let g:{varname}=F_opts_to_str({
          \ 'rbi_force'             : 1,
          \ 'rbi_discard_loaddat'   : 1,
          \ 'selectdialog'          : 1,
          \} )

"""perl_local_modules
     elseif varname == 'perl_local_modules'
        "let g:perl_local_modules=base#readdatfile('modules_all')

                let cmd='pmi --searchdirs ' . $PERLMODDIR . '/lib --print names ^'
            let g:{varname} = base#splitsystem( cmd )

"""perl_used_modules
     elseif varname == 'perl_used_modules'
        call base#setglobalvarfromdat('perl_used_modules',{
            \       'type'              : 'List', 
            \       'splitlines'        : 1,
            \       'select_fields'     : '0',
            \   })

        let g:perl_used_modules_paths=base#readdictdat('perl_used_modules')

"""perl_installed_modules
     elseif varname == 'perl_installed_modules'
        call base#datupdate('perl_installed_modules')

        call base#setglobalvarfromdat('perl_installed_modules',{
            \       'type'              : 'List', 
            \       'splitlines'        : 1,
            \       'select_fields'     : '0',
            \   })

        let g:perl_installed_modules_paths=base#readdictDat('perl_installed_modules')

     elseif varname == 'PMOD_perltopics'
         let g:PMOD_perltopics=base#readdatfile('PerlTopics')
        
         for id in base#qw("statements AUTOLOAD _DATA__ attributes ")
              call extend(g:PMOD_perltopics,base#readdatfile('PerlTopics_' . id ))
         endfor

     elseif base#inlist(varname,[ 
            \   'path', 
            \   'filename_root', 
            \   'filename',
            \   'fileinfo',
            \   'dirname',
            \   'ext',
            \   ])

        call base#getfileinfo()

     elseif varname == 'PMOD_ModuleName'

        LFUN F_sss
        call base#old#varupdate('path')

        if &ft == 'perl'
            let g:{varname}=F_sss('get_perl_package_name.pl --ifile ' . g:path )
        else
            let g:{varname}=''
        endif

     elseif varname == 'APACHE_Files'
        let g:{varname}=base#readdictDat(varname)

        call base#old#varupdate('APACHE_FilesList')

     elseif varname == 'APACHE_FilesList'
        call base#varcheckexist('APACHE_Files')

        let g:{varname}=sort(keys(g:APACHE_Files))

     elseif varname == 'vim_funcs_user'
        call base#var(varname,
            \   base#fnamemodifysplitglob('funs','*.vim',':t:r')
            \   )

     elseif varname == 'vim_coms'
        let g:vim_coms=base#fnamemodifysplitglob('vimcom','*.vim',':t:r')

     elseif varname == 'DC_ProjsDir'
        let g:DC_ProjsDir=s:paths['projs']

     elseif varname == 'DC_ProjsFile'
        let g:DC_ProjsFile=base#catpath('projs','PROJS.i.dat')

     elseif varname == 'DC_MkProjsFile'
        let g:DC_MkProjsFile=base#catpath('projs','MKPROJS.i.dat')

     elseif varname == 'projs'
        let g:projs=base#readdatfile('PROJS')

     elseif varname == 'mkprojs'
        let g:mkprojs=base#readdatfile('MKPROJS')

     elseif varname == 'DC_List_Pdf_Projs'
        let g:DC_List_Pdf_Projs=base#fnamemodifysplitglob('pdfout','*.pdf',':t:r')
        "
        " calculate intersection of arrays 
        "   g:DC_List_Pdf_Projs and g:projs
        "
        let projs=[]
      
        for proj in g:DC_List_Pdf_Projs
          if index(g:projs,proj) >=0
            call add(projs,proj)
          endif
        endfor
      
        let g:DC_List_Pdf_Projs=projs

"""DC_FilledProjs
     elseif varname == 'DC_FilledProjs'
          let g:DC_FilledProjs=[
            \ 'Metcalf_Fortran90_Explained',
            \ 'apsc',
            \ 'Dict',
            \ ]

"""DC_VimHelpFiles
     elseif varname == 'F_VimHelpFiles'
          call base#varreset( varname ,{})
          for path in split(globpath(&rtp, 'doc/*.txt' ),"\n")
            let vh=fnamemodify(path,':t:r')
            let g:{varname}[vh]=path
          endfor

"""DC_pdf_docs
     elseif varname == 'DC_pdf_docs'

            call base#varreset(varname,{})

"""_pdf_docs
            if exists("s:paths.pdfdocs")
                
                let dir=s:paths['pdfdocs']
                let docs={}

                if len(dir) 
    
                    let docs[dir]=base#fnamemodifysplitglob('pdfdocs','*.pdf',':p:t:r')
        
                    let docs[dir]=base#findunix({  'path'              : 'pdfdocs', 
                              \       'relpath'           : 1, 
                              \       'ext'               : 'pdf',
                              \       'fnamemodify'       : ':r',
                              \       })
        
                    let edocs={
                          \   '~/wrk/ap/oia/myR/' : [
                              \ 'OP_to_OIA_confirmation_letter', 
                              \ 'OP_to_OIA_further_remarks',
                                \   ],
                          \    '~/doc/fortran/' : [
                                \   'Metcalf-Fortran90-Explained',
                                \   ],
                          \    '~/wrk/ap/oia/myR': [ 'R1', 'R2', 'R3' ],
                          \    '~/wrk/ap/oia/UC/': map(base#listnewinc(0,30,1),"'UC-' . v:val")
                          \ }
        
                    call extend(docs,edocs)
        
                    for dir in keys(docs)
                      for docid in docs[dir]
                        let docpath=dir . '/' . docid . '.pdf'
                        call extend(g:{varname},{ docid : docpath })
                      endfor
                    endfor

                endif

            endif

"""varupdate_opts
     elseif varname == 'opts'

          call base#setglobalvarfromdat('opts',{ 'type' : 'Dictionary' })

    elseif varname == 'pathsep'

        let g:{varname}= '/'
         if has('win32')
            let g:{varname}= '\'
         endif

"""varupdate_datfiles
    elseif varname == 'datfiles'
        
        call base#varcheckexist([ 'paths', 'pathsep' ])

        let s:datfiles={}
        let file = base#catpath('mkvimrc','datfiles.i.dat') 

        let s:datfiles = base#readdatpaths({ 
            \ 'rootdir'   : base#path('mkvimrc'),
            \ 'file'      : file,
            \ 'ext'       : '.i.dat',
            \ })


"""datfiles_pp
      let vars=[
        \ 'vars_goossens',
        \ 'vars_htlatex',                        
        \ 'vars',                                
        \ ]

      for id in vars
        let s:datfiles['pp_' . id]=base#catpath('p',id . '.i.dat')
      endfor

      call base#var('datfiles_mkvimrc',s:datfiles)
      call base#var('datlist_mkvimrc',base#varhash#keys('datfiles_mkvimrc'))

"""varupdate_allmenus
      elseif varname == 'allmenus'
          LCOM PrjMake

          let g:{varname}={}

          for i in base#listnewinc(1,10,1)
            let g:{varname}[ 'ToolBar.sep' . i ]=  {
                  \ 'item'    : '-sep' . i .'-',  
                  \ 'fullcmd' : 'an ToolBar.-sep' . i . '- <Nop>',  
                  \ }
          endfor

          let menus={
            \ 'ToolBar.PlainTexRun' : {
                  \ 'icon' : 'PlainTexRun', 
                  \ 'item' : 'ToolBar.PlainTexRun', 
                  \ 'cmd'  : 'PlainTexRun', 
                  \ 'tmenu': 'PlainTexRun' },
            \ 'ToolBar.MAKE' : {
                  \ 'icon' : 'MAKE', 
                  \ 'item' : 'ToolBar.MAKE',  
                  \ 'cmd'  : 'PrjMake', 
                  \ 'tmenu': 'MAKE' },
            \ 'ToolBar.VIEWPDF' : {
                  \ 'icon' : 'VIEWPDF', 
                  \ 'item' : 'ToolBar.VIEWPDF', 
                  \ 'cmd'  : 'call DC_PrjView("pdf")', 
                  \ 'tmenu': 'View PDF' },
            \ 'ToolBar.VIEWLOG' : {
                  \ 'icon' : 'VIEWLOG',   
                  \ 'item' : 'ToolBar.VIEWLOG', 
                  \ 'cmd'  : 'call DC_PrjView("log")', 
                  \ 'tmenu': 'View TeX Log File' },
            \ 'ToolBar.MAIN' : {
                  \ 'icon' : 'MAIN', 
                  \ 'item' : 'ToolBar.MAIN',  
                  \ 'cmd'  : 'VSECBASE _main_', 
                  \ 'tmenu': 'Open root project file' },
            \ 'ToolBar.BODY' : {
                  \ 'icon' : 'BODY', 
                  \ 'item' : 'ToolBar.BODY',  
                  \ 'cmd'  : 'VSECBASE body', 
                  \ 'tmenu': 'Open body TeX file' },
            \ 'ToolBar.PREAMBLE' : {
                  \ 'icon' : 'PREAMBLE', 
                  \ 'item' : 'ToolBar.PREAMBLE',  
                  \ 'cmd'  : 'VSECBASE preamble', 
                  \ 'tmenu': 'Open preamble TeX file' },
            \ 'ToolBar.PACKAGES' : {
                  \ 'icon' : 'PACKAGES', 
                  \ 'item' : 'ToolBar.PACKAGES',  
                  \ 'cmd'  : 'VSECBASE packages',
                  \ 'tmenu': 'Open TeX file with packages' ,
                  \ },
            \ 'ToolBar.DEFS' : {
                  \ 'icon' : 'DEFS', 
                  \ 'item' : 'ToolBar.DEFS',  
                  \ 'cmd'  : 'VSECBASE defs',
                  \ 'tmenu': 'Open TeX file with definitions' ,
                  \ },
            \ 'ToolBar.HTLATEX' : {
                  \ 'icon' : 'HTLATEX', 
                  \ 'item' : 'ToolBar.HTLATEX', 
                  \ 'cmd'  : 'PrjMakeHTLATEX',
                  \ 'tmenu': 'Run TeX4HT using HTLATEX' ,
                  \ },
            \ 'ToolBar.VIEWHTML' : {
                  \ 'icon' : 'VIEWHTML', 
                  \ 'item' : 'ToolBar.VIEWHTML',  
                  \ 'cmd'  : 'PrjViewHtml',
                  \ 'tmenu': 'View generated HTML' ,
                  \ },
            \ 'TOOLS.VIEWPDF' : {
                  \ 'item' : '&TOOLS.&VIEWPDF', 
                  \ 'tab' : 'View\ compiled\ PDF',  
                  \ 'cmd' : 'call DC_PrjView("pdf")', 
                  \ },
            \ 'TOOLS.VIEWLOG' : {
                  \ 'item' : '&TOOLS.&VIEWLOG', 
                  \ 'tab' : 'View\ TeX\ Log\ file', 
                  \ 'cmd' : 'call DC_PrjView("log")', 
                  \ },
            \ 'TOOLS.VIEW.idx' : {
                  \ 'item' : '&TOOLS.&VIEW.&idx', 
                  \ 'tab' : 'View\ idx',  
                  \ 'cmd' : 'call DC_PrjView("idx")', 
                  \ },
            \ 'TOOLS.VIEW.ind' : {
                  \ 'item' : '&TOOLS.&VIEW.&ind', 
                  \ 'tab' : 'View\ ind',  
                  \ 'cmd' : 'call DC_PrjView("ind")', 
                  \ },
            \ 'TOOLS.VIEW.aux' : {
                  \ 'item' : '&TOOLS.&VIEW.&aux', 
                  \ 'tab' : 'View\ aux',  
                  \ 'cmd' : 'call DC_PrjView("aux")', 
                  \ },
            \ 'TOOLS.VIEW.lof' : {
                  \ 'item' : '&TOOLS.&VIEW.&lof', 
                  \ 'tab' : 'View\ lof',  
                  \ 'cmd' : 'call DC_PrjView("lof")', 
                  \ },
            \ 'TOOLS.VIEW.lot' : {
                  \ 'item' : '&TOOLS.&VIEW.&lot', 
                  \ 'tab' : 'View\ lot',  
                  \ 'cmd' : 'call DC_PrjView("lot")', 
                  \ },
            \ 'TOOLS.RWPACK' : {
                  \ 'item' : '&TOOLS.&RWPACK',  
                  \ 'tab' : 'Rewrite\ packages',  
                  \ 'cmd' : 'call DC_PrjRewritePackages()', 
                  \ },
            \ }

          call extend(g:{varname},menus)

"""allmenus_PERL
          LFUN Prl_module_subs

          let menus={
            \ 'PERL.module_subs' : {
                  \ 'item' : '&PERL.&module_subs',  
                  \ 'tab' : 'List\ subroutines',  
                  \ 'cmd' : 'echo Prl_module_subs()', 
                \   },
            \   }

          call extend(g:{varname},menus)

          call base#varcheckexist('OMNI_CompOptions_List')
          let omnitopics={
                \ 'PERL' : [
                      \ 'perl_used_modules', 
                      \ 'perl_local_modules', 
                      \ 'perl_installed_modules',
                      \ 'perl_subs_traveltek',
                      \ 'perl_module_subs',
                      \ ],
                \ 'TEX' : [
                      \ '_smart_tex',
                      \ 'TEXHT_CfgNames',
                      \ 'tex_TEXHT_commands',
                      \ 'tex_latex_commands_graphics',
                      \ 'tex_latex_commands_text',
                      \ 'tex_latex_environments',
                      \ 'tex_latex_packages',
                      \ 'tex_latex_pagestyles',
                      \ 'tex_plaintex_commands',
                      \ ],
                \ 'PROJS' : [
                      \ 'proj_defs',
                      \ 'proj_secs',
                      \ 'projs',
                      \ ],
                \ 'PAPS' : [
                      \ 'pap_isecs',
                      \ 'pap_pdf_papers',
                      \ 'pap_tex_papers',
                      \ 'bibkeys',
                      \ ],
                \ 'TAGS' : [
                      \ 'ctags_tagids',
                      \ ],
                \ 'VIM' : [
                      \ 'vimperlfuncs',
                      \ 'vim_commands_user',
                      \ 'vim_funcs_core',
                      \ 'vim_funcs_user',
                      \ ],
                \ 'OTHER' : [
                      \ 'snippets',
                      \ ],
                \ }

          let g:menus_omni={}
          for omni in g:OMNI_CompOptions_List
              let omnitopic=''
              let item='OMNI.' . omni

              for [topic,opts] in items(omnitopics)
                if base#inlist(omni,opts)
                  let omnitopic='&' . topic . '.'
                endif
              endfor

              let menuitem={
                  \ 'item' : '&OMNI.' . omnitopic . '&' . omni,
                  \ 'cmd'  : 'OMNIFUNC ' . omni,
                  \ }
              let g:{varname}[item]=menuitem
              call extend(g:menus_omni,{ item : menuitem })

          endfor

"""TXT
     elseif varname == 'TXT_venclose_structnames'
       RFUN TXT_Setup

"""TEXHT
     elseif varname == 'TEXHT_CfgNames'
       let g:{varname}=[]

       call base#varcheckexist('texinputs')

       for dir in g:texinputs
          let files=base#findunix({
                \ 'dir'           : dir,
                \ 'ext'           : 'tex',
                \ 'startpattern'  : '_cfg.',
                \ 'fnamemodify'   : ':p:t',
                \})

          call map(files,"matchstr(v:val,'" . '^_cfg\.\zs.*\ze\.tex$' . "')" )
          call extend(g:{varname},files)
       endfor

"""varupdate_texinputs
     elseif varname == 'texinputs'
       let g:{varname}=[]
       if exists("$TEXINPUTS")
          let g:{varname}=base#uniq(split($TEXINPUTS,':'))
       endif

"""TEX
     elseif varname == 'TEX_PlainTexMacros'
       let g:{varname}=sort(base#findunix({
        \ 'dir' : s:paths['tex'] . '/texmf-dist/tex/plain',
        \ 'ext' : 'tex',
        \ 'relpath' : 1,
        \}))

     elseif varname == 'TEXHT_Files'
       let g:{varname}=[]
     
     let dirs=[
        \ 'tex/generic/tex4ht',
        \ 'tex4ht',
        \ ]

     for dir in dirs
       let files=sort(base#findunix({
          \ 'dir' : g:texlive['TEXMFDIST'] . '/' . dir,
          \ 'ext' : 'tex,env,4ht',
          \} ))
       
       call map(files,"matchstr(v:val,'^' . g:texlive['TEXMFDIST'] . '/\\zs.*\\ze$' )")

       call extend(g:{varname},files)
     endfor

     elseif varname == 'TEX_PlainTexExamples'
       let g:{varname}=sort(base#findunix({
        \ 'dir' : s:paths['tex'] . '/texmf-dist/doc/plain',
        \ 'ext' : 'tex',
        \ 'relpath' : 1,
        \}))

     elseif varname == 'texlive'
       LFUN TEX_kpsewhich

       let g:{varname}={
             \  'TEXMFDIST'  : TEX_kpsewhich('--var-value=TEXMFDIST'),
             \  'TEXMFLOCAL' : TEX_kpsewhich('--var-value=TEXMFLOCAL'),
             \  }

     elseif varname == 'TEX_TexCmds'
       let g:{varname}=sort(base#fnamemodifysplitglob('p',"texcmd.*.tex",':r:e'))

     elseif varname == 'TEX_TexDefs'
       let g:{varname}=sort(base#fnamemodifysplitglob('p',"def.*.tex",':r:e'))

     elseif base#inlist(varname, [
          \ 'TEX_InsertEntries',
          \ 'TEX_TexDocEntries',
          \ 'TEX_latex_environments',
          \ 'TEX_latex_commands_text',    
          \ 'TEX_latex_commands_graphics',
          \ ])

       let g:{varname}=base#readdatfile(varname)

"""TEX_TexPackages
     elseif varname == 'TEX_TexPackages'

       call base#varcheckexist('TEX_LatexPackages')
       let g:{varname}=base#readdatfile(varname)

       "call filter(g:{varname},'base#inlist(v:val,g:TEX_LatexPackages)')

     elseif varname == 'TEX_TexTopics'
       let g:{varname}=sort(base#fnamemodifysplitglob('p',"htex.*.tex",':r:e'))

     elseif varname == 'TEX_LatexPackages'
       let g:{varname}=base#findunix({ 
            \   'dir'           : g:texlive['TEXMFDIST'] . '/tex/latex/', 
            \   'type'          : 'd', 
            \   'maxdepth'      : 1, 
            \   'fnamemodify'   : ':t',
            \   } )


     elseif varname == 'DC_Proj_SecOrderFile'
        let g:{varname}=base#catpath('texdocs', g:proj . '.secorder.i.dat' )

"""VVP_all_vimrcpieces
     elseif varname == 'VVP_all_vimrcpieces'
        let g:VVP_all_vimrcpieces=base#fnamemodifysplitglob('mkvimrc','*.vim',':t')

     elseif varname == 'TXT_used_keymaps'
        let g:TXT_used_keymaps=base#readdatfile('used_keymaps')

     elseif varname == 'DC_Proj_usedpacks' || varname == 'DC_Proj_packopts'
        RFUN DC_Proj_GetPackages

   elseif varname == 'LASU_IgnoredWarnings'
      let g:{varname} =join(base#readdatfile(varname,{ 'splitlines' : '0' }),"\n")

   elseif varname == 'LASU_IgnoreLevel'

     call base#varcheckexist('LASU_IgnoredWarnings')

     let g:{varname}=len(g:LASU_IgnoredWarnings)

"""LASU_FoldedMisc
   elseif varname == 'LASU_FoldedMisc'

          " Folding items which are not caught in any of the standard commands,
          " environments or sections.
          let s =  join(base#readdatfile('LASU_FoldedMisc'),",")
          if !exists('g:LASU_FoldedMisc')
            let g:LASU_FoldedMisc = s
          elseif g:LASU_FoldedMisc[0] == ','
            let g:LASU_FoldedMisc = s . g:LASU_FoldedMisc
          elseif g:LASU_FoldedMisc =~ ',$'
            let g:LASU_FoldedMisc = g:LASU_FoldedMisc . s
          endif

"""LASU_FoldedCommands
   elseif varname == 'LASU_FoldedCommands'

      let s=''
          if !exists('g:LASU_FoldedCommands')
            let g:LASU_FoldedCommands = s
          elseif g:LASU_FoldedCommands[0] == ','
            let g:LASU_FoldedCommands = s . g:LASU_FoldedCommands
          elseif g:LASU_FoldedCommands =~ ',$'
            let g:LASU_FoldedCommands = g:LASU_FoldedCommands . s
          endif

"""LASU_FoldedEnvironments
   elseif varname == 'LASU_FoldedEnvironments'
          let s =  join(base#readdatfile('LASU_FoldedEnvironments'),",")
                        
          if !exists('g:LASU_FoldedEnvironments')
                let g:LASU_FoldedEnvironments = s
          elseif g:LASU_FoldedEnvironments[0] == ','
                let g:LASU_FoldedEnvironments = s . g:LASU_FoldedEnvironments 
          elseif g:LASU_FoldedEnvironments =~ ',$'
                let g:LASU_FoldedEnvironments = g:LASU_FoldedEnvironments . s
          endif

"""LASU_FoldedSections
   elseif base#inlist(varname,[ 'LASU_FoldedSections' ]) 
         exe 'let g:' . varname . "= join(base#readdatfile(varname),',')" 

"""LASU_FoldedSectionEnds
   elseif base#inlist(varname,[ 'LASU_FoldedSectionEnds' ]) 
         exe 'let g:' . varname . '= base#readdatfile(varname)' 

"""perl_loaded_modules
   elseif varname == 'perl_loaded_modules'
        let g:perl_loaded_modules_paths={}
        let g:perl_loaded_modules=[]

"""DICT_dicts
   elseif varname == 'DICT_dicts'

         let g:DICT_dicts={}
        
         let lines=base#readdatfile('DICT_dicts', { 'splitlines': 0} )
         for line in lines
           let vars=split(line,'\s\+')
        
           let dictkey=remove(vars,0)
           let dirkey=remove(vars,0)
           let fname=remove(vars,0)
        
           let dirkey=substitute(dirkey,'_\(\w\+\)_','\1','g')
        
           let dir=get(s:paths,dirkey)
        
           if isdirectory(dir)
            let filepath=dir . '/' . fname
            let g:DICT_dicts[dictkey]=filepath
           endif
         endfor
        
         let g:DICT_dict_list=sort(keys(g:DICT_dicts))

     elseif varname == 'CTAGS_CMD'
        
         let g:CTAGS_CMD={
                \ 'tex' : 'ctags -R ',
                \}

     elseif varname == 'VH_acts'
        call base#setglobalvarfromdat(varname)

     elseif varname == 'CTAGS_ListLangs'
         let g:CTAGS_ListLangs=base#splitsystem("ctags --list-languages")

     elseif varname == 'CTAGS_CtagsFiles'
         let g:CTAGS_CtagsFiles=base#fnamemodifysplitglob('tags','*.tags',':t:r')

     elseif varname == 'CTAGS_tagnames'

        """let_tagnames
        let g:CTAGS_tagnames={
            \ '_gops_B_ff_' : 'gops_B',
            \ '_mkvimrc_'   : 'mkvimrc',
            \ '_lasu_'      : 'lasu',
            \}

     elseif varname == 'INC'
        let g:INC=split(system("perl -e 'print join(\":\",@INC);'"),':')

     elseif varname == 'CTAGS_tagdirs'
         let g:CTAGS_tagdirs={}
        
         let g:CTAGS_tagdirs={
                \ '_gops_B_ff_'   : s:paths['gops'] . '/B',
                \ '_mkvimrc_'     : s:paths['mkvimrc'],
                \ '_lasu_'        : s:paths['lasu'],
                \ '_proj_'        : s:paths['projs'],
                \ 'vh_perldoc'    : s:paths['plugins'] . '/perldoc/doc',
                \}
        
         for id in base#qw(" _paptex_  repdoc_bib psh_pl ")
            let g:CTAGS_tagdirs[id]=s:paths['p']
         endfor

     
     elseif varname == 'tagfile'
       let g:tagfile=''

     elseif varname == 'tagfiles'
       let g:tagfiles=[]

     elseif varname == 'F_tex_omnifuncs'

        let g:F_tex_omnifuncs=[
          \ 'tex_math',
          \ 'tex_plaintex',
          \ ]

"""RE
     elseif varname == 'RE'
        let g:{varname}=base#readdictDat(varname)

"""varupdate_plugins
    elseif base#inlist(varname, [
          \ 'plugins',
          \ 'plugin_acts',
          \ ] )
      
        let g:{varname}=base#readdatfile(varname)


    elseif varname == 'allplugins'
        let g:{varname}=base#findunix( { 
            \   'dir'       : s:paths['plugins'], 
            \   'type'      : 'd'   ,
            \   'maxdepth'  : 1     ,
            \   'mindepth'  : 1     ,
            \   'sort'      : 1     ,
            \   'fnamemodify'  : ':p:h:t'     ,
            \   } )

"""varupdate_pluginfiles
     elseif varname == 'pluginfiles'

        call base#varcheckexist('plugins')

        if exists("g:plugin")

            let g:plugindir=base#catpath('plugins',g:plugin)

            let g:plugindirs=base#findunix({ 
                \   'dir'       : g:plugindir,
                \   'type'      : 'd',
                \   'maxdepth'  : 1,
                \   'mindepth'  : 1,
                \   'fnamemodify'  : ':t',
                \   } )

            let g:{varname}=base#findunix({ 
                    \   'dir' : g:plugindir,
                    \   'ext' : 'vim',
                    \   })

            call map(g:{varname},"substitute(v:val,'^' . g:plugindir . '[/]*','','g')")

        else
            call base#subwarn('g:plugin variable is not set.')

        endif

     elseif varname == 'pluginroot'
        let g:pluginroot='_plugins'

     elseif varname == 'allplugins'

        call base#old#varupdate('pluginroot')
    
          let g:allplugins=base#fnamemodifysystem('find ' 
              \ . $VIMRUNTIME 
              \ . '/' . g:pluginroot . ' -maxdepth 1 -type d ',
              \ ':t:r'
              \ )

     elseif varname == 'VarUpdateOptions'
        let g:{varname}=base#readdatfile(varname)

"""vhook
     elseif varname == 'vhookTOC'
        call base#varreset('g:vhookTOC',[])
        call extend(g:vhookTOC,VH_linesTOC())

     elseif varname == 'vhookroot'
      LFUN VH_GetHooks
      LFUN VH_SetHooks

      call VH_GetHooks()
      call VH_SetHooks()

     elseif varname == 'SNI_available_snippet_extensions'
       let exts=[]
     call base#varcheckexist('SNI_snippetdirs')

       for snidir in g:SNI_snippetdirs
         call extend(exts, base#fnamemodifysystem('find ' . snidir . ' -name *.snippets',':t:r'))
       endfor

     call base#varreset(varname,sort(base#uniq(exts)))

     elseif varname == 'SNI_snippetdirs'
      call base#varcheckexist('rtp')
        let snidirs=base#readdatfile('snippetdirs')

    call base#varreset(varname,[])

    for snidir in snidirs
      for rtpdir in g:rtp
          let dir=rtpdir . '/' . snidir
        if isdirectory(dir)
          call add(g:SNI_snippetdirs,dir)
          endif
      endfor
    endfor

"""varupdate_ctagsexe
  elseif varname == 'ctagsexe'
        let g:{varname} = 'ctags'

"""varupdate_rtp
     elseif varname == 'rtp'
        let g:rtp=[ ]

        call base#old#varupdate('plugins')
        call base#old#varupdate('pluginroot')

        call add(g:rtp,$VIMRUNTIME)

        for plugin in g:plugins
           let pdir=$VIMRUNTIME . '/' .  g:pluginroot . '/' . plugin
           if isdirectory(pdir)
              call add(g:rtp,pdir)
           endif
        endfor

        call add(g:rtp,$VIMRUNTIME . '/after')

        let &rtp=join(g:rtp,',')

"""varupdate__dat__
     elseif base#inlist(varname,base#readdatfile('VarUpdateDat'))
           if base#inlist(varname,[
                 \   'TEX_plaintex_commands', 
                 \   'TEX_TEXHT_commands', 
                 \] )
              let g:{varname}=base#readdatfile(varname,{ 'splitlines' : 0 })

           elseif  varname == 'PAP_parts'
          let g:{varname}=
            \ base#readdatfile('pap.parts',{ 'select_fields' : '0' } )

       else
              let g:{varname}=base#readdatfile(varname)
           endif

"""varupdate_PAP_bibkeys
  elseif varname == 'PAP_bibkeys'

    if base#opttrue('usepsh')
        let g:{varname}=base#splitsystem("pshcmd list bibkeys")
    else

perl << EOF
 
      use LaTeX::BibTeX;
      use Vim::Perl qw( Vim_Files VimLet );
      
      my @keys;
      
      my $bibfile = new LaTeX::BibTeX::File(Vim_Files('bibfile'));
      
      while ($entry = new LaTeX::BibTeX::Entry $bibfile)
      {
        next unless $entry->parse_ok;
        push(@keys,$entry->key);
      }
      VimLet('g:PAP_bibkeys',\@keys);

EOF
      endif

     elseif varname == 'DC_Proj_Defs'
        call base#varcheckexist('proj')
        let g:{varname}=base#readdatfile({ 
                \   'file' : base#catpath('projs', g:proj . '.defs.i.dat' ) ,
                \   'splitlines' : 0,
                \   })
    
     elseif varname == 'TXT_CommentChars'
        let g:{varname}={
              \ 'vim'   : '"',
              \ 'perl'  : '#',
              \ 'tex'   : '%',
              \ }

     elseif varname == 'commentchar'
        let g:{varname}="#"

     elseif varname =~ 'F_'

     else
         let notdone=1
    endif

    if exists('notdone')
          echohl WarningMsg
          echo "base#varupdate> Not yet implemented: " . varname
          echohl None
    endif
 
endfunction

