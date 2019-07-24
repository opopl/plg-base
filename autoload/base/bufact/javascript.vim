
" BaseDatView comps_BufAct_javascript
"
function! base#bufact#javascript#exe_split ()
	call base#buf#start()

	let cmd = 'node ' . b:file
	let ok = base#sys({ 
		\	"cmds"         : [cmd],
		\	"split_output" : 1,
		\	"skip_errors"  : 1,
		\	})
	let out    = base#varget('sysout', [] )
	let outstr = base#varget('sysoutstr','')
	
endfunction

"""js_syntax_check
function! base#bufact#javascript#syntax_check ()
	call idephp#buf#js_syntax_check ()

endfunction

function! base#bufact#javascript#tabs_nice ()
	try
			 %s/\([\t]\+\)\s*/\1/g
			 %s/->\s\+/->/g
	catch 
	 		echo v:exception
	endtry

endfunction
