
function! base#dat_vis#open ()
	let lines = base#vim#visual_selection()

	call base#buf#open_split({ 'lines' : lines })
	
endfunction
