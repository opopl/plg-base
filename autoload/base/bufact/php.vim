
function! base#bufact#php#set_ft_html ()
	call base#buf#start()
	call base#html#htw_load_buf()

	setlocal ft=html
	
endfunction

function! base#bufact#php#syntax_check ()
	call base#buf#start()
	call base#html#htw_load_buf()

	setlocal makeprg=php\ -l\ %
	setlocal errorformat=%m\ in\ %f\ on\ line\ %l	

	AsyncMake
endfunction

function! base#bufact#php#exec_async ()
	call base#buf#start()
	call base#html#htw_load_buf()

	setlocal makeprg=php\ %
	setlocal errorformat=%m\ in\ %f\ on\ line\ %l	

	AsyncMake
endfunction

function! base#bufact#php#echo_tag ()
	call base#buf#start()
	call base#html#htw_load_buf()

	let tag = base#input_we('html tag: ','',{})

	"single quote
	let sq = "'"

	"double quote
	let dq = '"'

	" array where the php output will be stored
	let lines = []

	call add(lines,"echo " . sq . '<' . tag . '>' . sq . ';' )
	call add(lines,"echo " . '"\n";' )
	call add(lines,"echo " . sq . '</' . tag . '>' . sq)

	call append('.',lines)

endfunction

