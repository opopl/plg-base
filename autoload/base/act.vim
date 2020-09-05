
function! base#act#list_vim_commands ()

  let coms = base#vim#list_coms ()
  echo coms
  
endfunction

function! base#act#envvar_open_split (...)
  let envv = input('Env variable:','','environment')
  call base#envvar_open_split(envv)

endfunction

function! base#act#file_view (...)
  let fileid = get(a:000,0,'')

  while !strlen(fileid)
    let msg    = 'fileid: '
    let fileid = base#input_we(msg,'',{
      \ 'complete' : 'custom,base#complete#db_fileids' })
  endw

  let file = base#db#file_path(fileid)

  call base#fileopen({ 'files': [ file ] })
endfunction

function! base#act#au_print (...)

  if exists("ww") | unlet ww | endif

  let ww=''
  redir => ww
  silent au
  redir END

  let wwa = split(ww,"\n")
  call base#buf#open_split({ 'lines' : wwa })

endfunction

function! base#act#buf_onload (...)
  call base#buf#onload()
endfunction

"""buf_filetype_view_snippets
function! base#act#buf_filetype_view_snippets (...)
   if strlen(&ft)
      call snipMate#SnippetView(&ft)
   endif
endfunction

"""thisfile_copy_to
function! base#act#thisfile_copy_to (...)
  let file     = expand('%:p')
  let basename = expand('%:p:t')

  let msg_a = [ 
      \ 'This will copy the current file ' ,
      \ '   into another location;'        ,
      \ 'Enter destination dirid: '
      \ ]

  let msg   = join(msg_a,"\n")
  let dirid = base#input_we(msg,'',{ 'complete' : 'custom,base#complete#CD' })
  let dir   = base#path(dirid)

  let msg_a = [ 
      \ '',
      \ 'This dirid corresponds to directory:' ,
      \ ' ' . dir,
      \ 'Now enter the destination subpathqw - space separated list',
      \ ' of subdirectory parts, e.g. entering "a b c" corresponds to ',
      \ ' subdirectory a/b/c.',
      \ ' subpathqw: ',
      \ ]
  let msg = join(msg_a,"\n")
  let subpathqw = base#input(msg,'',{ 'do_redraw' : 1 })

  " destination directory
  let dir_dest = base#qw#catpath(dirid, subpathqw)
  
  let new = base#file#catfile([ dir_dest, basename ])

  let msg_a = [ 
      \ '',
      \ 'New file location is:' ,
      \ ' ' . new,
      \ 'Copy? (1/0): ',
      \ ]
  let msg = join(msg_a,"\n")
  if !base#input(msg, 1) | return | endif

  call base#file#copy(file, new, { 'prompt' : 1 })
endfunction

"""buffs_loclist
function! base#act#buffs_loclist (...)
  let exts_s = base#input_we('extensions (separated by space) : ','',{})
  let exts   = split(exts_s," ")
  
  "" retrive list of buffers from ls command
  let bref     = base#buffers#get()
  let bufs     = get(bref, 'bufs', [])
  let buffiles = get(bref, 'buffiles', [])

  let llist = []
  for bff in buffiles
    let ext = fnamemodify(bff,':e')
    if base#inlist(ext, exts)
       call add(llist,{ 'filename' : bff, 'text' : fnamemodify(bff,':t') })
    endif
  endfor

  if len(llist)
    call setloclist(winnr(), llist)
    lopen
  endif

endfunction

function! base#act#lopen ()
  call base#loclist#open()
endfunction

function! base#act#lclose ()
  call base#loclist#close()
endfunction

function! base#act#copen ()
  call base#qf_list#open()
endfunction

function! base#act#cclose ()
  call base#qf_list#close()
endfunction

function! base#act#last_split_open ()
  let list = base#varget('last_split_lines',[])
  call base#buf#open_split({ 'lines' : list })

endfunction

function! base#act#cnv (...)
  let cmd = 'cnv'
  
  let env = {}
  function env.get(temp_file) dict
    let temp_file = a:temp_file
    let code = self.return_code
  
    if filereadable(a:temp_file)
      let out = readfile(a:temp_file)
      call base#buf#open_split({ 'lines' : out })
    endif
  endfunction
  
  call asc#run({ 
    \ 'cmd' : cmd, 
    \ 'Fn'  : asc#tab_restore(env) 
    \ })

endfunction

function! base#act#install_env ()
	let cmd = base#qw#catpath('plg','base bin install_env.pl')
	
	let env = {}
	function env.get(temp_file) dict
		let temp_file = a:temp_file
		let code = self.return_code
	
		if filereadable(a:temp_file)
			let out = readfile(a:temp_file)
			call base#buf#open_split({ 'lines' : out })
		endif
	endfunction
	
	call asc#run({ 
		\	'cmd' : cmd, 
		\	'Fn'  : asc#tab_restore(env) 
		\	})

endfunction

function! base#act#async_run (...)
  let cmd = get(a:000,0,'')

  let env = {}
  function env.get(temp_file) dict
      let h = ''
      "if self.return_code == 0
        " use tiny split window height on success
        "let h = 1
      "endif
      " open the file in a split
      exec h . "split " . a:temp_file
      
      if filereadable(a:temp_file)
        let out = readfile(a:temp_file)
        call base#varset('last_async_output',out)
      endif
      " remove boring build output
      "%s/^\[xslt\].*$/
      " go back to the previous window
      wincmd p
  endfunction
  
  " tab_restore prevents interruption when the task completes.
  " All provided asynchandlers already use tab_restore.
  call asc#run({ 'cmd' : cmd, 'Fn' : asc#tab_restore(env) })

endfunction

if 0
  call tree
  calls
    base#paths_to_db
endif

function! base#act#paths_to_db (...)
  call base#paths_to_db()
endfunction

function! base#act#paths_from_db (...)
  call base#paths_from_db()
endfunction

function! base#act#dict_view (...)
  let dicts = split(&dict,',')

  for dict in dicts
    if filereadable(dict)
      call base#fileopen({'files':[dict]})
    endif
  endfor

endfunction

function! base#act#perl_Vim_Plg_Base (...)

perl << eof
  use Vim::Plg::Base;
  use Vim::Perl qw(:funcs :vars);

  our $plgbase ||=  Vim::Base::Plg->new;

  VimCmd(qq{ let sub=input('Vim::Base::Plg method:','','custom,base#complete#perl_Vim_Plg_Base' ) });
  my $sub = VimVar('sub');

  $plgbase->$sub();
eof

endfunction


function! base#act#rtp_helptags ()
  call base#rtp#helptags()

endfunction

""look opts_BaseAct.i.dat
function! base#act#open_split_list ()
   
  let listvar = input('List variable:','','custom,base#complete#varlist_list')
  let list    = base#varget(listvar,[])

  call base#list#open_split(list)

endfunction

function! base#act#dump_buf_vars ()
  let buf_num = input('buffer number: ','')
  let val = base#buf#vars_buf(buf_num)

  let ds = base#dump_split(val)
  call base#buf#open_split({ 'lines' : ds })

endfunction

function! base#act#data_xml_list_files ()
  let f = globpath(&rtp,'/data/xml/*.xml')

  let files = split(f,"\n")

  let cmds_pre = []
  call add(cmds_pre,'resize 99')
  call add(cmds_pre,"vnoremap <buffer><silent> v :'<,'>call base#vis_act#open_file()<CR>")

  call base#buf#open_split({ 
    \ 'lines'      : files ,
    \ 'cmds_pre'   : cmds_pre,
    \ 'stl_add'    : [ 'V[ v - view ]' ],
    \ })
  
endfunction

function! base#act#plg_loadvars ()
  let msg_a = [
    \  "This will run base#plg#loadvars() subroutine",  
    \  " ",  
    \  "Plugin: ",  
    \  ]
  let msg = join(msg_a,"\n")
  let plg = base#input_we(msg,'projs',{ 'complete' : 'custom,base#complete#plg' })

  call base#plg#loadvars(plg)
endfunction
