"used in:
"		base#bufact#php#tggen_phpctags

function! base#fc#tggen_phpctags (self,temp_file)
	let self      = a:self
	let temp_file = a:temp_file
	
  let code  = self.return_code

  let tfile = self.tfile
  let cmd   = self.cmd

	let ok = 1
	let ok = ok && (code == 0)
	let ok = ok && (filereadable(tfile))

	let out = []
	call extend(out,[ 'Command: ', "\t" . cmd ])
	if filereadable(a:temp_file)
			call extend(out,[ 'Output: '])
			call extend(out, base#map#add_tabs(readfile(a:temp_file),1))
	endif

	if ok
			redraw!
			echohl MoreMsg
			echo 'OK: tggen_phpctags'
			echohl None

			exe 'setlocal tags='.escape(tfile,'\ ')
	else
			redraw!
			echohl WarningMsg
			echo 'FAIL: tggen_phpctags'
			echohl None

			call base#buf#open_split({ 'lines' : out })
	endif
endfunction
