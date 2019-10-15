
function! base#bufact#perl#pod_to_text ()
	call base#buf#start()

	let cmd = join([ 'pod2text', shellescape(b:file), '' ],' ')

	let ok = base#sys({ 
		\	"cmds"         : [cmd],
		\	"split_output" : 0,
		\	})

	let out    = base#varget('sysout',[])
	call base#buf#open_split({ 'lines' : out })

endf
