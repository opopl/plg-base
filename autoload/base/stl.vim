
function! base#stl#set (...)

    if a:0
      let opt=a:1
    else
      let opt='neat'

      let listcomps=g:F_StatusLineKeys
  
      let liststr = join(listcomps,"\n")
      let dialog  = "Available status line keys  are: " . "\n"
      let dialog .= base#createprompt(liststr, 1, "\n") . "\n"
      let dialog .= "Choose status line key by number: " . "\n"

      let opt = base#choosefromprompt(dialog,liststr,"\n",'neat')
      echo "Selected: " . opt

    endif

	let evs=''
	let sline = ''

	if opt == 'ap'
		call ap#stl()
        let sline  = &stl
	elseif exists('g:F_StatusLines')
        let sline  = get(g:F_StatusLines,opt)
        let evs    = "setlocal statusline=" . sline
        let g:F_StatusLine      = opt
        let g:F_StatusLineOrder = []

        if exists('g:F_StatusLineOrders[opt]')
            let g:F_StatusLineOrder=g:F_StatusLineOrders[opt]
        endif
	endif
	if strlen(evs) | silent exe evs | endif

	call base#var('stl',sline)

endfun

function!  base#stl#setparts ()

 LFUN F_IgnoreCase
 LFUN F_SoPiece

 "call base#sopiece("NeatStatusLine.vim")
 call F_SoPiece("NeatStatusLine.vim")

"""stl_neat
  let g:stlparts={}

    " mode (changes color)
  let g:stlparts['mode']= '%1*\ %{NeatStatusLine_Mode()}\ %0*' 

  let g:stlparts['fold_level']="%5*%{foldlevel(line('.'))}%0*"

"""stl_neat_session_name
    " session name
  let g:stlparts['session_name']='%5*\ %{g:neatstatus_session}\ %0*' 

"""stl_neat_file_path
    " file path
  let g:stlparts['file_name']="%{expand('%:p:t')}" 

  let g:stlparts['file_name']="%{ap#plg#name()}" 

  let g:stlparts['bush_name']="%{expand('%:p:t:r')}" 

  let g:stlparts['file_dir']="%{expand('%:p:h:')}" 

  let g:stlparts['full_file_path']="%{expand('%:p')}" 

"""stl_neat_file_flags
    " read only, modified, modifiable flags in brackets
	let g:stlparts['file_flags']='%([%R%M]%)' 
	
	" right-align everything past this point
	let g:stlparts['right_align']= '%=' 
    
"""stl_neat_read_only
	" readonly flag
	let g:stlparts['read_only']="%{(&ro!=0?'(readonly)':'')}"
	
	" file type (eg. python, ruby, etc..)
	let g:stlparts['file_type']= '%8*%{&filetype}%0*' 
	
	let g:stlparts['keymap']= '%8*%{&keymap}' 
	
	" file format (eg. unix, dos, etc..)
	let g:stlparts['file_format']='%{&fileformat}'

  " file encoding (eg. utf8, latin1, etc..)
	let g:stlparts['file_encoding']= "%4*%{(&fenc!=''?&fenc:&enc)}%0*"

	let g:stlparts['encoding']= "%4*%{&enc}%0*"


  " buffer number
	let g:stlparts['buffer_number']='#%n'

  "line number (pink) / total lines
	let g:stlparts['line_number']='%4*\ %l%0*'

  " column number (minimum width is 4)
  let g:stlparts['column_number'] = '%3*\ %-3.c%0*'

  let g:stlparts['ignore_case']   = '%{F_IgnoreCase()}'

    let g:stlparts['color_red']   = '%3*'
    let g:stlparts['color_blue']  = '%8*'
    let g:stlparts['color_white'] = '%0*'

    let g:stlparts['plg_name'] = '%1*\ %{ap#plg#name()}\ %0*'

    " percentage done
    let g:stlparts['percentage_done']='(%-3.p%%)'

    " modified / unmodified (purple)
    let g:stlparts['is_modified']="%6*%{&modified?'modified':''}"

    let g:stlparts['projs_proj'] = '%1*\ %{projs#proj#name()}\ %0*' 
    let g:stlparts['projs_sec']  = '%7*\ %{projs#proj#secname()}\ %0*' 

    let g:stlparts['vimfun']= '%1*\ %{g:vimfun}\ %0*' 
    let g:stlparts['vimcom']= '%1*\ %{g:vimcom}\ %0*' 
    let g:stlparts['vimproject']= '%1*\ %{g:vimproject}\ %0*' 

    let g:stlparts['stlname']= '%2*\ %{g:F_StatusLine}\ %0*' 

    let g:stlparts['tags']= '%{fnamemodify(&tags,' . "'" . ':~' . "'" . ')}' 

    let g:stlparts['tgids'] = '%1*\ %{base#tg#ids_comma()}\ %0*' 

    let g:stlparts['makeprg']='%1*\ %{&makeprg}' 

	let g:stlparts['column_number']='%3*\ %-3.c%0*'
	
	let g:stlparts['ignore_case']='%{F_IgnoreCase()}'

	let g:stlparts['color_red']='%3*'
	let g:stlparts['color_blue']='%8*'
	let g:stlparts['color_white']='%0*'
	
	" percentage done
	let g:stlparts['percentage_done']='(%-3.p%%)'
	
	" modified / unmodified (purple)
	let g:stlparts['is_modified']="%6*%{&modified?'modified':''}"

	let g:stlparts['plg_name'] = '%1*\ %{ap#plg#name()}\ %0*' 
	
	let g:stlparts['projs_proj'] = '%1*\ %{projs#proj#name()}\ %0*' 
	let g:stlparts['projs_sec']  = '%7*\ %{projs#proj#secname()}\ %0*' 
	
	let g:stlparts['vimfun']= '%1*\ %{g:vimfun}\ %0*' 
	let g:stlparts['vimcom']= '%1*\ %{g:vimcom}\ %0*' 
	let g:stlparts['vimproject']= '%1*\ %{g:vimproject}\ %0*' 
	
	let g:stlparts['stlname']= '%2*\ %{g:F_StatusLine}\ %0*' 
	
	let g:stlparts['tags']= '%{fnamemodify(&tags,' . "'" . ':~' . "'" . ')}' 
	
	let g:stlparts['makeprg']='%1*\ %{&makeprg}' 
	
	"call base#varupdate('PMOD_ModuleName')
    let g:stlparts['perl_module_name']   ='%5*\ %{perlmy#modname()}\ %0*' 
    let g:stlparts['path_relative_home'] ='%{expand(' . "'" . '%:~:t' . "'" . ')}'

endfun

fun! base#stl#setlines(...)

  let g:F_StatusLineOrders={}

  let g:F_StatusLines={
    \  'enc' : '%<%f%h%m%r%=format=%{&fileformat}\ file=%{&fileencoding}\ enc=%{&encoding}\ %b\ 0x%B\ %l,%c%V\ %P',
        \  'vim_COM' :   ''
                \   . '\ %{expand(' . "'" . '%:~:t:r' . "'" . ')}' ,
    \   }

  for key in keys(g:F_StatusLines)
    let g:F_StatusLineOrders[key]=[]
  endfor

  call base#stl#setparts()

  let g:F_StatusLineOrders={
        \   'enc'   :   [ 
                \   'file_name',
                \   'file_format',
                \   'file_type',
                \   'encoding',
                \   'file_encoding',
                \       ],
        \   'perl_pm'   :   [ 
		        \   'perl_module_name',
                \           ],
        \   'perl_pl'   :   [ 
		        \   'file_name',
		        \   'file_dir',
                \       ],
        \   'simple'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   'file_encoding',
                \       ],
        \   'plg'   :   [ 
		        \   'plg_name',
		        \   'buffer_number',
		        \   'file_name',
                \       ],
        \   'neat'   :   [ 
		        \   'tgids'          ,
		        \   'mode'          ,
		        \   'session_name'  ,
		        \   'file_name'     ,
		        \   'file_flags'    ,
		        \   'right_align'   ,
		        \   'read_only'     ,
		        \   'file_type'     ,
		        \   'file_format'   ,
		        \   'file_encoding' ,
		        \   'buffer_number' ,
		        \   'is_modified'   ,
		        \   ],
        \   'vimfun'   :   [ 
		        \   'vimfun',
		        \   'tgids'          ,
		        \   ],
        \   'vimproject'   :   [ 
		        \   'vimproject',
		        \   ],
        \   'vim'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   'tgids'          ,
		        \   ],
        \   'dat'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   ],
        \   'sh'   :   [ 
		        \   'file_name',
		        \   'file_dir',
		        \   ],
        \   'bush'   :   [ 
		        \   'bush_name',
		        \   ],
        \   'vimcom'   :   [ 
		        \   'vimcom' ,
		        \   'tgids'  ,
		        \   ],
        \   'projs'   :   [ 
		        \   'buffer_number'    ,
		        \   'projs_proj'    ,
		        \   'projs_sec'     ,
		        \   'fold_level'    ,
		        \   'file_encoding' ,
		        \   'encoding'      ,
		        \   'keymap'        ,
		        \   'tgids'         ,
		        \   ],
        \   }

  let g:F_StatusLineKeys=sort(keys(g:F_StatusLineOrders))

  for var in [ 'F_StatusLineBefore', 'F_StatusLineAfter' ]
 	call base#setglobalvarfromdat(var, { 'splitlines': 1 } )
  endfor

  for key in g:F_StatusLineKeys
       let stl=''

       let idlist=[]
       let idlist=copy(g:F_StatusLineBefore)
       call extend(idlist,g:F_StatusLineOrders[key])
       call extend(idlist,g:F_StatusLineAfter)

       for id in idlist
         let stl.='\ ' . g:stlparts[id]
       endfor

       let g:F_StatusLines[key]=stl
  endfor

""========================================================
  let g:F_StatusLines['perl_']=g:F_StatusLines['perl_pl']

endfun

