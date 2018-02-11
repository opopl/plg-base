
function! base#opt#true ()
	
endfunction

"function! base#opt#get (opt)
"function! base#opt#get ([ opt ])
"function! base#opt#get ([ opt1,opt2 ])

function! base#opt#get (...)
  let aa   = a:000
	let optnames = get(aa,0,'')

	let opts=base#varget('opts',{})

  if type(optnames)==type('')
      let opt = optnames
	    let val = get(opts,opt,'')
	    return val
  elseif type(optnames)==type([])
      let optvals={}
      for opt in optnames
         call extend(optvals,{ opt : base#opt#get(opt) })
      endfor
      return optvals
  endif
	
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

	let oldval = base#opt#set(opt,val)
	call base#echo({ 'text' : 'Option reset: '.opt. ' => ' . val  })

	call base#echoprefixold()
endfunction

function! base#opt#echo (...)

	let opt = get(a:000,0,'')
	let opts = base#varget('opts',{})
	if !strlen(opt)
		call base#var#dump_split('opts')
		return
	endif

	if !base#opt#defined(opt)
		call base#echo({ 'text' : 'Option Undefined: ' . opt })
	else
		let val = get(opts,opt,'')
		call base#echo({ 'text' : opt . ' => ' . val })
	endif

endfunction

"function! base#opt#set (opt,val)
"function! base#opt#set ({ opt : val })
"
function! base#opt#set (...)
  let aa=a:000

  let opt = get(aa,0,'')
  let val = get(aa,1,'')

  let ref={}
  if type(opt) == type('')
     let ref={ opt : val }
  elseif type(opt) == type({})
     call extend(ref,opt)
  endif

	let opts = base#varget('opts',{})
	call extend(opts,ref)

	call base#varset('opts',opts)
endfunction

function! base#opt#save (...)
	let aa  = a:000
	let opt = get(aa,0,'')

	if !len(opt)
		let opt = input('Option:','','custom,base#complete#opts')
		if !len(opt) | redraw! | echo '' | return | endif 
	endif

	let val = base#opt#get(opt)

	let saved=base#varget('opts_saved',{})
	call extend(saved,{ opt : val })

	call base#varset('opts_saved',saved)
endfunction

function! base#opt#restore (...)
	let aa  = a:000
	let opt = get(aa,0,'')

	if !len(opt)
		let opt = input('Option:','','custom,base#complete#opts')
		if !len(opt) | redraw! | echo '' | return | endif 
	endif

	let saved = base#varget('opts_saved',{})
	let sv    = get(saved,opt,'')

	if len(sv)
		call base#opt#set(opt,sv)
		if has_key(saved,opt)
			call remove(saved,opt)
		endif
		call base#varset('opts_saved',saved)
	endif
endfunction
