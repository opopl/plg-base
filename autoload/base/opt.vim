
function! base#opt#true ()
	
endfunction

function! base#opt#get (opt)
	let opt = a:opt

	let opts=base#varget('opts',{})
	let val = get(opts,opt,'')
	return val
	
endfunction

function! base#opt#defined (opt)
	let opt = a:opt
	let opts = base#varget('opts',{})

	if exists("opts['".opt."']")
		return 1
	endif
	return 0

endfunction

"call base#opt#reset ()
"call base#opt#reset (opt)
"call base#opt#reset (opt,val)

function! base#opt#reset (...)
	call base#echoprefix('')

	let aa = a:000

	let opt = get(aa,0,'' )
	let val = get(aa,1,'')

	if !len(opt)
		let opt = input('Option:','','custom,base#complete#opts')
		if !len(opt) | redraw! | echo '' | return | endif 
	endif
	if !len(val)
		let val = input('Value to set:','')
		if !len(val) | redraw! | echo '' | return | endif 
	endif

	let oldval = base#opt#get(opt)
	call base#echo({ 'text' : 'Old option value: '.oldval  })

	call base#echo({ 'text' : 'Option reset: '.opt. ' => ' . val  })

	call base#echoprefixold()
endfunction

function! base#opt#echo (...)

	if a:0
		let opt = a:1
	else
		let opt = input('Option:','','custom,base#complete#opts')
	endif
	let opts = base#varget('opts',{})

	if !base#opt#defined(opt)
		call base#echo({ 'text' : 'Option Undefined: ' . opt })
	else
		let val = get(opts,opt,'')
		call base#echo({ 'text' : opt . ' => ' . val })
	endif

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

	let saved = base#varget('opts_saved',{})
	let sv    = get(saved,opt,'')

	if len(sv)
		call base#varset(opt,sv)
		if exists("saved['".opt."']")
			call remove(saved,opt)
		endif
		call base#varset('opts_saved',saved)
	endif
endfunction
