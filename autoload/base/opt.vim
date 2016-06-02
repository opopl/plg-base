
function! base#opt#true ()
	
endfunction

function! base#opt#get (opt)
	let opt = a:opt

	let opts=base#varget('opts',{})
	let val = get(opts,opt,'')
	return val
	
endfunction

function! base#opt#set (opt,val)
	let opt = a:opt
	let val = a:val

	let opts=base#varget('opts',{})
	call extend(opts,{ opt : val })

	call base#varset('opts',opts)
endfunction

function! base#opt#save (opt)
	let opt = a:opt

	let val = base#opt#get(opt)

	let saved=base#varget('opts_saved',{})
	call extend(saved,{ opt : val })

	call base#varset('opts_saved',saved)
endfunction

function! base#opt#restore (opt)
	let opt = a:opt
endfunction
