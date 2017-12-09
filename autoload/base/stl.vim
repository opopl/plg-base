
function! base#stl#set (...)

    if a:0
      let opt=a:1
    else
      let opt='neat'

      let listcomps=base#varget('stlkeys',[])
  
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

	elseif base#varexists('statuslines')
    let sline  = base#varhash#get('statuslines',opt,'')
    let evs    = "setlocal statusline=" . sline

    call base#varset('statusline',opt)
    call base#varset('statuslineorder',[])

    if base#varhash#haskey('stlorders',opt)
        let stlorder=base#varhash#get('stlorders',opt)
				call base#varset('statuslineorder',stlorder)
    endif
	endif
	if strlen(evs) | silent exe evs | endif

	call base#var('stl',sline)
	call base#var('stlopt',opt)

endfun

function!  base#stl#setparts ()

 LFUN F_IgnoreCase
 LFUN F_SoPiece

 "call base#sopiece("NeatStatusLine.vim")
 call F_SoPiece("NeatStatusLine.vim")

"""stl_neat
  let stlparts={}

    " mode (changes color)
  let stlparts['mode']= '%1*\ %{NeatStatusLine_Mode()}\ %0*' 

  let stlparts['pathids']= '%3*\ %{base#buf#pathids_str()}\ %0*' 

  let stlparts['fold_level']="%5*%{foldlevel(line('.'))}%0*"

"""stl_neat_session_name
    " session name
  let stlparts['session_name']='%5*\ %{g:neatstatus_session}\ %0*' 

"""stl_neat_file_path
    " file path
  let stlparts['file_name']="%{expand('%:p:t')}" 

  let stlparts['bush_name']="%{expand('%:p:t:r')}" 

  let stlparts['file_dir']="%{expand('%:p:h:')}" 

  let stlparts['full_file_path']="%{expand('%:p')}" 

"""stl_neat_file_flags
    " read only, modified, modifiable flags in brackets
	let stlparts['file_flags']='%([%R%M]%)' 
	
	" right-align everything past this point
	let stlparts['right_align']= '%=' 
    
"""stl_neat_read_only
	" readonly flag
	let stlparts['read_only']="%{(&ro!=0?'(readonly)':'')}"
	
	" file type (eg. python, ruby, etc..)
	let stlparts['file_type']= '%8*%{&filetype}%0*' 
	
	let stlparts['keymap']= '%8*%{&keymap}' 
	
	" file format (eg. unix, dos, etc..)
	let stlparts['file_format']='%{&fileformat}'

  " file encoding (eg. utf8, latin1, etc..)
	let stlparts['file_encoding']= "%4*%{(&fenc!=''?&fenc:&enc)}%0*"

	let stlparts['encoding']= "%4*%{&enc}%0*"
	let stlparts['base_buftype']= "%4*%{base#buf#type()}%0*"

	let stlparts['gitdir'] = "%4*Dir[%{base#varget('stl_gitcmd_dirname')}]%0*"
	let stlparts['gitcmd'] = "%3*%{base#varget('stl_gitcmd_cmd')}%0*"

  " buffer number
	let stlparts['buffer_number']='#%n'

  "line number (pink) / total lines
	let stlparts['line_number']='%4*\ %l%0*'

  " column number (minimum width is 4)
  let stlparts['column_number'] = '%3*\ %-3.c%0*'

  let stlparts['ignore_case']   = '%{F_IgnoreCase()}'

  let stlparts['color_red']   = '%3*'
  let stlparts['color_blue']  = '%8*'
  let stlparts['color_white'] = '%0*'

  let stlparts['plg_name'] = '%1*\ %{ap#plg#name()}\ %0*'

  " percentage done
  let stlparts['percentage_done']='(%-3.p%%)'

  " modified / unmodified (purple)
  let stlparts['is_modified']="%6*%{&modified?'modified':''}"

  let stlparts['projs_rootbasename'] = '%1*\ %{projs#rootbasename()}\ %0*' 
  let stlparts['projs_proj'] = '%2*\ %{projs#proj#name()}\ %0*' 
  let stlparts['projs_sec']  = '%7*\ %{projs#proj#secname()}\ %0*' 

  let stlparts['vimfun']= '%1*\ %{g:vimfun}\ %0*' 
  let stlparts['vimcom']= '%1*\ %{g:vimcom}\ %0*' 
  let stlparts['vimproject']= '%1*\ %{g:vimproject}\ %0*' 

  let stlparts['stlname']= '%2*\ %{g:F_StatusLine}\ %0*' 

  let stlparts['tags']= '%{fnamemodify(&tags,' . "'" . ':~' . "'" . ')}' 

  let stlparts['tgids'] = '%1*\ %{base#tg#ids_comma()}\ %0*' 

  let stlparts['makeprg']='%1*\ %{&makeprg}' 

	let stlparts['column_number']='%3*\ %-3.c%0*'
	
	let stlparts['ignore_case']='%{F_IgnoreCase()}'

	let stlparts['color_red']='%3*'
	let stlparts['color_blue']='%8*'
	let stlparts['color_white']='%0*'
	
	" percentage done
	let stlparts['percentage_done']='(%-3.p%%)'
	
	" modified / unmodified (purple)
	let stlparts['is_modified']="%6*%{&modified?'modified':''}"

	let stlparts['plg_name'] = '%1*\ %{ap#plg#name()}\ %0*' 
	
	let stlparts['vimfun']= '%1*\ %{g:vimfun}\ %0*' 
	let stlparts['vimcom']= '%1*\ %{g:vimcom}\ %0*' 
	let stlparts['vimproject']= '%1*\ %{g:vimproject}\ %0*' 
	
	let stlparts['stlname']= '%2*\ %{g:F_StatusLine}\ %0*' 
	
	let stlparts['tags']= '%{fnamemodify(&tags,' . "'" . ':~' . "'" . ')}' 
	
	let stlparts['makeprg']='%1*\ %{&makeprg}' 

	let stlparts['java_buf_appname'] = '%1*\ %{my_java#buf#appname()}\ %0*' 
	let stlparts['java_buf_package'] = '%1*\ %{my_java#buf#package()}\ %0*' 
	
	"call base#varupdate('PMOD_ModuleName')
  let stlparts['perl_module_name']   ='%5*\ %{perlmy#modname()}\ %0*' 
  let stlparts['path_relative_home'] ='%{expand(' . "'" . '%:~:t' . "'" . ')}'

	call base#varset('stlparts',stlparts)

endfun

function! base#stl#setorders ()

	call base#echo({ 'text' : 'base#stl#setorders()'})

	let stlorders={}
  for key in base#varhash#keys('statuslines')
    let stlorders[key]=[]
  endfor

"""base_stl_plg
  call extend(stlorders,{
        \   'enc'   :   [ 
                \   'file_name',
                \   'file_format',
                \   'file_type',
                \   'encoding',
                \   'file_encoding',
                \       ],
        \   'perl_pm'   :   [ 
		        \   'perl_module_name' ,
		        \   'buffer_number'    ,
		        \   'file_type'        ,
		        \   'file_encoding'    ,
		        \   'encoding'         ,
		        \   'pathids'          ,
		        \   'line_number'      ,
                \           ],
        \   'perl_pl'   :   [ 
		        \   'file_name',
		        \   'file_dir',
                \       ],
        \   'simple'   :   [ 
		        \   'buffer_number' ,
		        \   'line_number'   ,
		        \   'file_name'     ,
		        \   'file_encoding' ,
		        \   'encoding'      ,
                \       ],
        \   'java'   :   [ 
		        \   'buffer_number' ,
		        \   'line_number'   ,
		        \   'file_name'     ,
		        \   'file_encoding' ,
		        \   'encoding'      ,
		        \   'java_buf_appname'  ,
		        \   'java_buf_package'  ,
                \       ],
        \   'plg'   :   [ 
		        \   'plg_name'      ,
		        \   'line_number'   ,
		        \   'buffer_number' ,
		        \   'file_name'     ,
		        \   'tgids'         ,
        \       ],
        \   'php'   :   [ 
		        \   'line_number'   ,
		        \   'buffer_number' ,
		        \   'file_name'     ,
		        \   'tgids'         ,
        \       ],
        \   'neat'   :   [ 
		        \   'tgids'         ,
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
		        \   'line_number'    ,
		        \   ],
        \   'gitcmd'   :   [ 
		        \   'gitdir'          ,
		        \   'gitcmd'          ,
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
		        \   'line_number'    ,
		        \   'projs_rootbasename'    ,
		        \   'projs_proj'    ,
		        \   'projs_sec'     ,
		        \   'fold_level'    ,
		        \   'file_encoding' ,
		        \   'encoding'      ,
		        \   'keymap'        ,
		        \   'tgids'         ,
		        \   ],
        \   'tex'   :   [ 
		        \   'file_name'     ,
		        \   'file_dir'      ,
		        \   'buffer_number' ,
		        \   'line_number'   ,
		        \   'file_encoding' ,
		        \   'encoding'      ,
		        \   'keymap'        ,
		        \   'tgids'         ,
		        \   ],
        		\ })

	call base#varset('stlorders',stlorders)
	
endfunction

fun! base#stl#setlines(...)

  let statuslines={
    \  'enc' : '%<%f%h%m%r%=format=%{&fileformat}\ file=%{&fileencoding}\ enc=%{&encoding}\ %b\ 0x%B\ %l,%c%V\ %P',
        \  'vim_COM' :   ''
                \   . '\ %{expand(' . "'" . '%:~:t:r' . "'" . ')}' ,
    \   }
	call base#varset('statuslines',statuslines)

  call base#stl#setparts()
  call base#stl#setorders()

	let stlorders = base#varget('stlorders',{})
	let stlkeys   = base#varhash#keys('stlorders')

	call base#varset('stlkeys',stlkeys)

  for key in base#varget('stlkeys')
       let stl=''

       let idlist=[]
			 "
			 let sto=base#varhash#get('stlorders',key,[])

       call extend(idlist,sto)

       for id in idlist
         let stl.='\ ' . base#varhash#get('stlparts',id,'')
       endfor

       let statuslines[key]=stl
  endfor

  let statuslines['perl_']=get(statuslines,'perl_pl','')

	call base#varset('statuslines',statuslines)

endfun

