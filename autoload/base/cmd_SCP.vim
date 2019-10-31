
"""see also: base#cmd#SCP

function! base#cmd_SCP#list_bufs ()
	let buf_nums = base#scp#bufn()

	let data = [] 

	let cols_s = 'buf_num basename host port'
	let cols_s = input('columns:',cols_s)
	let cols = base#qw(cols_s)

	for buf_num in buf_nums
		let scp_data = base#buf#vars_buf(buf_num, 'scp_data', {})
		let ok_data =  len(scp_data) ? 1 : 0

		let row = []
		let row_h = {
				\	'buf_num'  : buf_num,
				\	}
		call extend(row_h, scp_data)

		for col in cols
			call add(row,get(row_h,col,''))
		endfor

		call add(data, row)
	endfor

	let lines = pymy#data#tabulate({
		\ 'data'    : data,
		\ 'headers' : cols,
		\ })
	
	call base#buf#open_split({ 'lines' : lines })

endfunction

"	Usage
"		call base#cmd_SCP#buf_add_tags ()
"	Call tree
"		Calls
"			base#scp#tags_make
"				base#scp#bufn
"				base#ctags#run
"				base#tags#add

function! base#cmd_SCP#tags_make ()
	call base#scp#tags_make()
endfunction

function! base#cmd_SCP#tags_set ()
	call base#scp#tags_set()
endfunction

function! base#cmd_SCP#dump_scp_data ()
	if !exists("b:scp_data")
		let m = 'No b:scp_data variable!'
		redraw!
		echohl WarningMsg
		echo m
		echohl None
		return
	endif

	let tabbed =  base#dump#dict_tabbed(b:scp_data)
	call base#buf#open_split({ 'lines' : tabbed })
	
endfunction
