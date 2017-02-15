
function! base#mkdir#prompt (...)
	let cwd = getcwd()
	let dir = get(a:000,0,'')

	if !strlen(dir)
		let dir = input('Directory to create:','')
	endif

	let relcwd = input('Relative path to cwd? (1/0):',1)

	if relcwd
		let dir = base#file#catfile([ cwd, dir ])
	endif

  if isdirectory(dir)
    return  1
  endif

  try
    call mkdir(dir,'p')
  catch
    call base#warn({ "text" : "Failure to create dir: " . a:dir})
  endtry
	
endfunction
