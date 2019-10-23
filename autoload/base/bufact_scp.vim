
function! base#bufact_scp#scp_send ()
	if !exists("b:scp_data") | return	| endif

	call base#scp#send({ 'scp_data' : b:scp_data })

endfunction

function! base#bufact_scp#scp_fetch ()
	if !exists("b:scp_data") | return	| endif

	call base#scp#fetch({ 'scp_data' : b:scp_data })
	
endfunction

function! base#bufact_scp#scp_data ()
	if !exists("b:scp_data") | return	| endif

	let lines = base#dump#dict_tabbed(b:scp_data)
	call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#bufact_scp#ssh_cmd ()
	if !exists("b:scp_data") | return	| endif

endfunction
