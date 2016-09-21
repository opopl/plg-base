 
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

