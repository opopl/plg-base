
function! base#bufact#python#exe ()
	call base#buf#start()

	let start = base#varget('bufact_start',0)
	let end   = base#varget('bufact_end',line('$'))

  let cmd = 'python ' . b:file
  let ok = base#sys({ 
          \        "cmds"         : [cmd],
          \        })
  let out    = base#varget('sysout',[])
  let outstr = base#varget('sysoutstr','')

  if len(out)
    call base#buf#open_split({ 'lines' : out })
  endif
		
endfunction

function! base#bufact#python#local_settings ()
	call base#buf#start()

	let start = base#varget('bufact_start',0)
	let end   = base#varget('bufact_end',line('$'))

	setlocal ts=2
		
endfunction
