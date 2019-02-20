"""BufAct_lynx_dump_split
function! base#bufact#vim#insert_snip ()
	call base#buf#start()

	let ft_old = exists('g:snippet_ft') ? g:snippet_ft : ''

	let g:snippet_ft = input('snippet ft:','','custom,snipMate#complete#snips')

	let snip = input('perl snippet:','','custom,snipMate#complete#snippetNames')

	call snipMate#SnippetInsert(snip)

	let g:snippet_ft = ft_old

endfunction



