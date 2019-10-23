
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

	let path_host = get(b:scp_data, 'path_host', '')

	let msg_a = [
		\	"ssh cmd: ",	
		\	]

	let msg = join(msg_a,"\n")
	let cmd = base#input_we(msg,'',{ })

	let start_dir = fnamemodify(path_host, ':h')
	let cmds_user = [ cmd ] 
	let cmd_core = burdev#opt#get("cmd_ssh_remote")
	
	let r = {
		\	'start_dir' : start_dir,
		\	'cmds_user' : cmds_user,
		\	'cmd_core'  : cmd_core,
		\	}
	call base#ssh#run(r)

endfunction
