
function! base#bufact#php#set_ft_html ()
  call base#buf#start()
  call base#html#htw_load_buf()

  setlocal ft=html
  
endfunction



function! base#bufact#php#tggen_phpctags()
  if !len(base#where('phpctags'))
    redraw!
    echohl WarningMsg
    echo 'No phpctags executable found in PATH! Aborting'
    echohl None
    return
  endif

  let rel_dir =  base#file#reldir_str (b:dirname,$USERPROFILE,{ 'sep' : '_' })
  let dir_tags = base#qw#catpath('tagdir php phpctags ' . rel_dir)
  call base#mkdir(dir_tags)

  let tfile_id = fnamemodify(b:basename, ':r' )
  let tfile    = base#file#catfile([ dir_tags, tfile_id . '.tags'])

  let tfile_se = shellescape(tfile)

  let cmd = printf('phpctags -f %s %s', tfile_se, b:file_se)
  
  let env = { 
    \ 'tfile' : tfile ,
    \ 'cmd'   : cmd ,
    \ }

  function env.get(temp_file) dict
    call base#fc#tggen_phpctags(self, a:temp_file)
  endfunction
  
  call asc#run({ 
    \  'cmd' : cmd, 
    \  'Fn'  : asc#tab_restore(env) 
    \  })

endfunction

function! base#bufact#php#tabs_nice ()

  try
    %s/\([\t]\+\)\s*/\1/g
    %s/$this->\s\+/$this->/g
    %s/->\s\+/->/g
  catch 
    echo v:exception
  endtry

endfunction

function! base#bufact#php#quotes_enclose ()
  let pats = []

  call add(pats, '%s/^\(\s*\)\(\w\+\)\(\s*=>\)/\1' . "'" . '\2'  . "'" . '\3/g' )
  call add(pats, '%s/\(\s\+\)\(\w\+\)\(\s*=>\)/\1' . "'" . '\2'  . "'" . '\3/g' )

  for pat in pats
    try
      exe pat 
    catch 
      let exc = v:exception
      let w = { 'text' : 'quotes_enclose ' . exc, 'prefix' : '' }
      call base#warn(w)
    endtry
  endfor

endfunction

"""php_syntax_check
function! base#bufact#php#syntax_check ()
  call idephp#buf#php_syntax_check ()
  
endfunction

function! base#bufact#php#server_run ()
  call base#buf#start()

  call base#cd(b:dirname)
  let port = base#input_we('port: ',8000,{})

  let cmd = 'AC php -S localhost:' . port . ' ' . shellescape(b:basename)
  exe cmd

endfunction

function! base#bufact#php#async_exe_Fc (self, temp_file)
	let self      = a:self
	let temp_file = a:temp_file

  let code = self.return_code
  
	let out = []
  if filereadable(a:temp_file)
    let out = readfile(a:temp_file)
  endif
	if len(out)
		call base#buf#open_split({ 'lines' : out })
	endif
endfunction

function! base#bufact#php#async_exe ()
  call base#buf#start()

  setlocal makeprg=php\ %
  setlocal errorformat=%m\ in\ %f\ on\ line\ %l 

	let execmd = printf('php %s', b:file_se)

  let env = { }
  function env.get(temp_file) dict
		call base#bufact#php#async_exe_Fc (self, a:temp_file)
  endfunction

  call asc#run({ 
    \ 'cmd' : execmd, 
    \ 'Fn'  : asc#tab_restore(env) 
    \ })
endfunction

function! base#bufact#php#async_server_run ()
  call base#buf#start()
  call base#html#htw_load_buf()


  let msg_a = [
    \ "port: ", 
    \ ]
  let msg = join(msg_a,"\n")
  let port = base#input_we(msg,5000,{ })

  let r = {
      \ 'port' : port,
      \ 'file' : b:file,
      \ }
  let blines = idephp#php#bat_lines_run_as_server(r)

  let ftmp = base#qw#catpath('tmp_bat bufact_php_async_server_run.bat')
  call writefile(blines,ftmp)

  let execmd = shellescape(ftmp)

  let env = { 'port' : port }
  function env.get(temp_file) dict
    let code = self.return_code
    let port = self.port
  
    if filereadable(a:temp_file)
      let out = readfile(a:temp_file)
    endif
  endfunction
  
  call asc#run({ 
    \ 'cmd' : execmd, 
    \ 'Fn'  : asc#tab_restore(env) 
    \ })
endfunction

function! base#bufact#php#echo_tag ()
  call base#buf#start()
  call base#html#htw_load_buf()

  let tag = base#input_we('html tag: ','',{})

  "single quote
  let sq = "'"

  "double quote
  let dq = '"'

  " array where the php output will be stored
  let lines = []

  call add(lines,"echo " . sq . '<' . tag . '>' . sq . ';' )
  call add(lines,"echo " . '"\n";' )
  call add(lines,"echo " . sq . '</' . tag . '>' . sq)

  call append('.',lines)

endfunction

