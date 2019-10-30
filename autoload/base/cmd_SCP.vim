
"""see also: base#cmd#SCP

function! base#cmd_SCP#list_bufs ()
	let buf_nums = base#scp#bufn()

	let data = [] 

	let cols = base#qw('buf_num rel_path bur_data scp_data')

	for buf_num in buf_nums
		let scp_data = base#buf#vars_buf(buf_num, 'scp_data', {})

		let rel_path = get(scp_data, 'rel_path' , '')

		let ok = {
			\	'scp_data' : len(scp_data) ? 1 : 0,
			\	}	

		if strlen(rel_path)
			let row = [ buf_num, rel_path ]

			call add(row,get(ok,'scp_data',''))

			call add(data, row)
		endif
	endfor

	let lines = pymy#data#tabulate({
		\ 'data'    : data,
		\ 'headers' : cols,
		\ })
	
	call base#buf#open_split({ 'lines' : lines })

endfunction

function! base#cmd_SCP#buf_load ()
	
endfunction
