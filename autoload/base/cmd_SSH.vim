
"""see also: base#cmd#SSH

function! base#cmd_SSH#run ()
	
endfunction

function! base#cmd_SSH#last_cmd_output ()
  let out = base#varget('ssh_run_out',[])
  call base#buf#open_split({ 'lines' : out })
	
endfunction
