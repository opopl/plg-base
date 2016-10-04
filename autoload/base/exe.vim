
"function! base#exe#run (exename,cmd)
"function! base#exe#run ('perl',cmd)
"
"function! base#exe#run ({ 'exename' : 'perl', 'cmd' : cmd })


function! base#exe#run (...)
  let aa  = a:000

  let ref = {}
  if a:0 && base#isdict(a:1)
    let ref = a:1
  endif

  let exename = get(aa,0,'')
  let cmd     = get(aa,1,'')

  let comp_cmd = ''

  if len(ref)
	  if type(ref) == type({}) 
	     let exename = get(ref,'exename','')
	     let cmd     = get(ref,'cmd','')
	     let comp_cmd     = get(ref,'comp_cmd','')
	  endif
  endif

  if !len(cmd)
     if len(comp_cmd)
        let cmd = input('Command for '.exename.':','--help',comp_cmd)
     else
        let cmd = input('Command for '.exename.':','--help')
     endif
  endif

  if !len(cmd) 
    call base#warn({ 'text' : 'No command for '.exename.', aborted'})
    return
  endif

  let exe = base#exe#select({ "exename" : exename })

  let cmd = join( [ '"'.exe.'"', cmd ],' ')
  call base#envcmd(cmd)

endfunction

function! base#exe#select (...)
	let ref = {}
	if a:0 | let ref = a:1 | endif

  let exename = get(ref,'exename','')
  let choice  = get(ref,'choice','')
	
  let exe   = exename
  let exes  = []
  let fpath = base#f#path(exename)

  if type(fpath)==type([])
     let exes = fpath
     let exe  = get(fpath,-1,'')
  elseif type(fpath)==type('')
     let exe  = fpath
     let exes = [ fpath ]
  endif


  if len(exes)
		 if len(choice)
			if choice == 'last'
					let exe = get(exes,-1,'')
			elseif choice == 'by_id'
					let id = get(ref,'id','')
					if len(id)
						let exe = get(pa_exes,id,'')
					endif
		 	endif
		 else
	    let exe =base#getfromchoosedialog({ 
	             \ 'list'        : exes,
	             \ 'startopt'    : exe,
	             \ 'header'      : "Available ".exename." exes are: ",
	             \ 'numcols'     : 1,
	             \ 'bottom'      : "Choose exe by number: ",
	            \ })
  	 endif
  endif

  return exe

endf	
