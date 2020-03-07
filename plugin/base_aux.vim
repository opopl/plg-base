
function! Plg_Base_Complete_DD(...)
  let comps = [
    \ 'texdocs',
    \ 'home',
    \ 'repos_git',
    \ ]
  return join(comps,"\n")
endf

function! Plg_Base_DD(...)
  let dirid = get(a:000,0,'')


  if dirid == 'texdocs'
    let dir = $userprofile . '\repos\git\texdocs'
  elseif dirid == 'repos_git'
    let dir = $userprofile . '\repos\git'
  elseif dirid == 'home'
    let dir = $userprofile
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
