
function! base#bufact_common#_file_add_to_db ()
	call base#buf#start()

	let fileid = base#input_we('fileid: ','',{})

	call base#db#file_add({ 
		\	'file'   : b:file, 
		\	'fileid' : fileid })
	
endfunction

function! base#bufact_common#tabs_to_spaces ()
  setlocal et | retab
endfunction
