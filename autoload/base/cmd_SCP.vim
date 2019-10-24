
"""see also: base#cmd#SCP

function! base#cmd_SCP#list_bufs ()
	let bf_all = base#buffers#get()

	let a = base#dump(bf_all)
	echo a

endfunction

function! base#cmd_SCP#buf_load ()
	
endfunction
