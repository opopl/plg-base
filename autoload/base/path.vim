
function! base#path#echo (pathid)
  echo base#path(a:pathid)
endfunction

function! base#path#cmd (...)
  let cmd  = get(cmd,0,'')
  let cmds = base#varget( 'cmds_BasePath', [] )

  if base#inlist(cmd, cmds)
    let c = 'call base#path#' . cmd . '()'
    exe c
  endif

endfunction

function! base#path#update (...)
  let pathid = get(a:000, 0, '')

  if !strlen(pathid)
    let pathid = base#input_we('pathid: ', '', { 'complete' : 'custom,base#complete#CD' })
  endif

  let path = base#path(pathid)

  let msg_a = [
    \ "", 
    \ "BasePathUpdate - change path/pathid data", 
    \ "", 
    \ "Which part to update? (1 - pathid, 2 - path): ", 
    \ ]

  let msg = join(msg_a,"\n")
  let iid = base#input_we(msg, 1, { })

  "" change pathid 
  if iid == 1 
    let pathid_new = base#input_we('new pathid: ', '', { 'complete' : 'custom,base#complete#CD' })

	  call base#path#delete(pathid)

	  call base#paths_update({
	    \ pathid_new : path
	    \ })

  "" change path
  elseif iid == 2 
    let path_new = base#input_we('new path: ', '', { })

	  call base#paths_update({
	    \ pathid : path_new
	    \ })
  endif


endfunction

function! base#path#add (...)
  let pathid = get(a:000,0,'')

  while !strlen(pathid)
    let pathid = input('New pathid: ', pathid, 'custom,base#complete#CD')
  endw

  let use_pwd = input('Use current dir? (1/0): ',1)
	let path = ''

  while 1
    if use_pwd
      let path = getcwd()
      break
    endif

    let path   = ''
    while !strlen(path)
      let path   = input('New pathid path: '  , path, 'file')
    endw

    break
  endw

  call base#paths_update({
    \ pathid : path
    \ })

	if path == base#path(pathid)
		redraw!
		echohl MoreMsg
		echo "SUCCESS: Pathid added: " . pathid
		echohl None
	endif

endfunction

function! base#path#delete (...)
  let pathid = get(a:000,0,'')

  let dbfile = base#dbfile()

  while !strlen(pathid)
    let pathid = input('Pathid: ', pathid, 'custom,base#complete#CD')
  endw

  call pymy#sqlite#query({
    \ 'dbfile' : dbfile,
    \ 'q'      : 'DELETE FROM paths WHERE pathid = ?',
    \ 'p'      : [pathid],
    \ })

  return
endfunction
