

function! base#info#datfiles ()

	let lines=[]
	let dbfile = base#dbfile()
	
	let type = input('dattype:','','custom,base#complete#dattypes')
	
	let q = 'select keyfull from datfiles where type = ?'
	let p = [type]
	
	let list = pymy#sqlite#query_as_list({
		\ 'dbfile' : dbfile,
		\ 'p'      : p,
		\ 'q'      : q,
		\ })
	let list = sort(list)
	call base#buf#open_split({ 
		\	'lines' : list })
endf	

if 0
	call tree
	called by
		base#info
endif

function! base#info#file ()
      call base#buf#start()

      let info = []

			let indent = base#varget('indent',2)

      call add(info,'General Info:')
      let info_g = [
      \ [ '(cwd)  dir   :', getcwd() ],
      \ [ '(cwd)  pathid:', base#pathid_cwd() ],
      \ ]

      let lines = pymy#data#tabulate({ 
        \ 'data'    : info_g,
        \ 'headers' : [],
        \ })
      call extend(info,base#map#add_tabs(lines,1))

      call extend(info,['FILE INFO:'])
      
      let info_a = [
      \ [ 'Current file:', expand('%:p') ],
      \ [ 'File directory (dirname):', expand('%:p:h') ],
      \ [ 'Filetype:', &ft ],
      \ [ 'Filesize:', base#file#size(b:file) ],
      \ ]

      let lines = pymy#data#tabulate({ 
        \ 'data'    : info_a ,
        \ 'headers' : [],
        \ })
      call extend(info,base#map#add_tabs(lines,1))

      call add(info,'Other variables:')
      let info_other = []

      let var_names  = base#qw("b:basename b:dirname b:file b:ext b:bufnr")

      for var_name in var_names
        let var_value = exists(var_name) ? eval(var_name) : ''

        call add(info_other,[ var_name, var_value ])
      endfor

      let lines = pymy#data#tabulate({ 
        \ 'data'    : info_other,
        \ 'headers' : [],
        \ })
      call extend(info,base#map#add_tabs(lines,1))

      call add(info,'Directories which this file belongs to:')
      let dirs_belong = base#buf#pathids_str()
      call add(info,indent . dirs_belong)

      if exists("b:other")
        call add(info,'OTHER INFO:')
        let y = base#dump#yaml(b:other)
        let y = base#map#add_tabs(y)
        call extend(info,y)
      endif

      if exists("b:aucmds")
        call add(info,'AUTOCOMMANDS:')
        call add(info,"\t".'b:aucmds:')
        let y = base#dump#yaml(b:aucmds)
        let y = base#map#add_tabs(y,2)
        call extend(info,y)

        if exists("b:augroup")
          call add(info,"\t".'b:augroup:')
          let y = base#dump#yaml(b:augroup)
          let y = base#map#add_tabs(y,2)
          call extend(info,y)
        endif
      endif

      if exists("b:html_info")
        call add(info,'HTML INFO:')
        let y = base#dump#yaml(b:html_info)
        let y = base#map#add_tabs(y)
        call extend(info,y)

      endif

      if exists("b:db_info")
          
        call add(info,'DB INFO:')
        let y = base#dump#yaml(b:db_info)
        let y = base#map#add_tabs(y)
        call extend(info,y)
      endif

      call base#buf#open_split({ 'lines' : info })
endf	


function! base#info#dbext ()
  let varnames = base#varget('varnames_dbext',[])

  let lines = []

  for varname in varnames
    let val = base#value#var(varname)
    let a = varname .' => '.val
    call add(lines,a)
  endfor

  call base#buf#open_split({ 'lines' : lines })
  
endfunction

function! base#info#topics ()
  let topics = base#varget('info_topics',[])
  let topics = sort(topics)
  return topics
endfunction

function! base#info#tags ()
  let tags  = split(&tags,",")
  
  let tgs   = base#tg#ids_comma()
  let tgids = split(tgs,',')
  
  let info = []
  
  call add(info, "Tag ID: ")
  for tgid in tgids 
    let tfile = base#tg#tfile(tgid)

    if base#inlist(tfile, tags )
      call add(info," " . tgid)
    endif
  endfor
  
  call add(info,'Tags: ')
  call add(info," &tags => ")
  
  for t in tags
    call add(info,"\t" . t )
  endfor
  
  call base#buf#open_split({ 'lines' : info })
endfunction

function! base#info#rtp ()
  let rtp_a = split(&rtp,",")
  
  let ii = []
  call add(ii,'&rtp:')
  call extend(ii,base#map#add_tabs(rtp_a,1))
  
  call base#buf#open_split({ 'lines' : ii })
endfunction

function! base#info#plugins ()
  let plugins = base#plugins()
  
  let ii = []
  call add(ii,'PLUGINS:')
  call extend(ii,base#map#add_tabs(plugins,1))
  call base#buf#open_split({ 'lines' : ii })
endfunction

