
"function! base#exe#run (exename,cmd)
"function! base#exe#run ('perl',cmd)

function! base#exe#run (...)
  let aa  = a:000

  let exename = get(aa,0,'')
  let cmd     = get(aa,1,'')

  if !len(cmd)
     let cmd = input('Command for '.exename.':','--help')
  endif

  if !len(cmd) 
    call base#warn({ 'text' : 'No command for '.exename.', aborted'})
    return
  endif

  let exe = exename
  let exes = []
  let fpath = base#fpath(exename)

  if type(fpath)==type([])
     let exes=fpath
     let exe = get(fpath,-1,'')
  elseif type(fpath)==type('')
     let exe = fpath
     let exes = [ fpath ]
  endif

  if len(exes)
     let exe =base#getfromchoosedialog({ 
             \ 'list'        : exes,
             \ 'startopt'    : exe,
             \ 'header'      : "Available ".exename." exes are: ",
             \ 'numcols'     : 1,
             \ 'bottom'      : "Choose exe by number: ",
             \ })
  endif
  let cmd = join( [ '"'.exe.'"', cmd ],' ')
  call base#envcmd(cmd)

endfunction
