
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

function! base#bufact#javascript#browserify ()
	 let result_js = b:dirname . '/_bundle.js' 
	 let cmd_a = [ 'browserify', shellescape(b:file), "-o", result_js ]
	 let cmd = join(cmd_a," ")

	 let env = { 'file' : b:file, 'result_js' : result_js }
	 function env.get(temp_file) dict
	 	let code = self.return_code
		let file = self.file
		let basename = fnamemodify(file,':t')

		let msg = 'browserify ' . basename . ' => ' . fnamemodify(self.result_js,':t')

		if code == 0
			redraw!
			echohl MoreMsg
			echo 'OK: ' . msg
		else
			redraw!
			echohl WarningMsg
			echo 'FAIL: browserify ' . basename
			echohl None
		endif
	 
	 	if filereadable(a:temp_file)
	 		let out = readfile(a:temp_file)
			call base#buf#open_split({ 'lines' : out })
	 	endif
	 endfunction
	 
	 call asc#run({ 
	 	\	'cmd' : cmd, 
	 	\	'Fn'  : asc#tab_restore(env) 
	 	\	})

endfunction

function! base#bufact#javascript#help_browserify ()

endfunction

function! base#bufact#javascript#tabs_nice ()
	try
			 %s/\([\t]\+\)\s*/\1/g
			 %s/->\s\+/->/g
	catch 
	 		echo v:exception
	endtry

endfunction
