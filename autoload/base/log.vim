
function! base#log#view_split ()

	let dbfile = base#dbfile()

	let q = 'select rowid,time,prf,msg from log'
	let rq = {
			\	'dbfile' : dbfile,
			\	'q'      : q,
			\	}
	let lines = pymy#sqlite#query_screen(rq)
	call base#buf#open_split({ 'lines' : lines })

	"let log = base#varget('base_log',[])
	"let lines=[]
	"for msg in log
		"call add(lines,get(msg,'msg',''))
	"endfor

	"call base#buf#open_split({ 'lines' : lines })
	
endfunction

function! base#log#clear ()
	call base#varset('base_log',[])

perl << eof
	if ($plgbase) {
		#$plgbase->;
	}
	
eof
endfunction

function! base#log#cmd (...)
	let cmd = get(a:000,0,'view_split')
	let sub = 'base#log#'.cmd
	exe 'call ' . sub . '()'

endfunction
