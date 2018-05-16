
function! base#svn#ls ()
		let cmd = 'svn ls'
		let ok = base#sys({ 
			\	"cmds"         : [cmd],
			\	"split_output" : 1,
			\	})
		let out    = base#varget('sysout',[])
		let outstr = base#varget('sysoutstr','')
			
endfunction

function! base#svn#status ()
		let cmd = 'svn status'
		let ok = base#sys({ 
			\	"cmds"         : [cmd],
			\	"split_output" : 1,
			\	})
		let out    = base#varget('sysout',[])
		let outstr = base#varget('sysoutstr','')

	
endfunction

function! base#svn#commit ()
	
endfunction
