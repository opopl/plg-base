
function! Plg_Base_Complete_DD(...)
  let comps = [
    \ 'home',
    \ 'plg',
    \ 'plg_base_autoload',
    \ 'repos_git',
    \ 'texdocs',
    \ ]
  return join(comps,"\n")
endf

function! Plg_Base_Complete_W(...)
  let comps = [
    \ 'base_init_vim',
    \ ]
  return join(comps,"\n")
endf

function! Plg_Base_W(...)
  let fileid = get(a:000,0,'')

  if dirid == 'base_init_vim'
	endif

endf

function! Plg_Base_DD(...)
  let dirid = get(a:000,0,'')


  if dirid == 'texdocs'
    let dir = $userprofile . '\repos\git\texdocs'
  elseif dirid == 'repos_git'
    let dir = $userprofile . '\repos\git'
  elseif dirid == 'home'
    let dir = $userprofile
  elseif dirid == 'plg'
    let dir = $userprofile . '\programs\vim\vim80\plg'
  elseif dirid == 'plg_base_autoload'
    let dir = $userprofile . '\programs\vim\vim80\plg\base\autoload'
  else
    redraw!
    echohl NonText
    echo 'NO SUCH DIRECTORY ' . dirid
    echohl None
  endif

  if !exists('dir')
    return
  endif

  if isdirectory(dir)
    exe 'cd ' . dir
    let b:dir = dir
    let b:dirid = dirid
  endif

  let cwd = getcwd()
  if cwd == dir
    redraw!
    echohl WildMenu
    echo 'CHANGED TO: ' . dir
    echohl None
  endif
endf

command! -nargs=1 -complete=custom,Plg_Base_Complete_DD DD
  \ call Plg_Base_DD(<f-args>)

command! -nargs=1 -complete=custom,Plg_Base_Complete_W W
  \ call Plg_Base_W(<f-args>)
