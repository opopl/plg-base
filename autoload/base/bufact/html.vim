

"""BufAct_lynx_dump_split
function! base#bufact#html#lynx_dump_split ()
	call base#buf#start()

	let lines = getline(0,'$') 
	let tmp   = tempname()
	call writefile(lines,tmp)
	let cmd = 'lynx -dump -force_html '.tmp
	echo tmp
	call base#sys({ "cmds" : [cmd], 'split_output' : 1 })

endfunction

"""BufAct_pretty_libxml
function! base#bufact#html#pretty_libxml ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let html_pp=base#html#pretty_libxml(html)
	call base#buf#open_split({ 'lines' : html_pp })

endfunction

function! base#bufact#html#xpath ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = idephp#hist#input({ 
			\	'msg'  : 'XPATH:',
			\	'hist' : 'xpath',
			\	})

	let filtered = []

	let filtered = base#html#xpath({
				\	'htmltext' : html,
				\	'xpath'    : xpath,
				\	})

	call base#buf#open_split({ 'lines' : filtered })

endfunction

function! base#bufact#html#quickfix_xpath ()
	call base#buf#start()

	let lines = getline(0,'$')
	let html  = join(lines,"\n")

	let xpath = idephp#hist#input({ 
			\	'msg'  : 'XPATH:',
			\	'hist' : 'xpath',
			\	})

	let lines = []

	let lines = base#html#xpath_lineno({
				\	'htmltext' : html,
				\	'xpath'    : xpath,
				\	})

	for line in lines
		 let text = get(line,'text','')
		 let r = {
		 		\	'filename' : b:file,
		 		\	'bufnr'    : b:bufnr,
		 		\	'text'     : strpart(text,0,50),
		 		\	}
		 call extend(line,r)
	endfor
  call setqflist(lines)	
	copen
 " setqflist({list} [, {action}])				*setqflist()*
		 "Create or replace or add to the quickfix list using the items
		"in {list}.  Each item in {list} is a dictionary.
		"Non-dictionary items in {list} are ignored.  Each dictionary
		"item can contain the following entries:
	
				"bufnr	buffer number; must be the number of a valid
				"buffer
				"filename	name of a file; only used when "bufnr" is not
				"present or it is invalid.
				"lnum	line number in the file
				"pattern	search pattern used to locate the error
				"col		column number
				"vcol	when non-zero: "col" is visual column
				"when zero: "col" is byte index
				"nr		error number
				"text	description of the error
				"type	single-character error type, 'E', 'W', etc.
	



endfunction

