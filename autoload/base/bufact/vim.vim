"""BufAct_lynx_dump_split
function! base#bufact#vim#insert_perl ()
	call base#buf#start()

	let ft_old = exists('g:snippet_ft') ? g:snippet_ft : ''

	let g:snippet_ft = 'perl'
	let snip = input('perl snippet:','','custom,snipMate#complete#snippetNames')

	call snipMate#SnippetInsert(snip)

	let g:snippet_ft = ft_old

endfunction

