
function! base#bufact#javascript#exe_split ()
	call base#buf#start()

	let cmd = 'node ' . b:file
	let ok = base#sys({ 
		\	"cmds"         : [cmd],
		\	"split_output" : 1,
		\	"skip_errors"  : 1,
		\	})
	let out    = base#varget('sysout',[])
	let outstr = base#varget('sysoutstr','')
	
endfunction
