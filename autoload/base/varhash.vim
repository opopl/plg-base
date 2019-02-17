
function! base#varhash#keys (var)
	let val = base#varget(a:var)

	let keys=[]
	if base#type(val) == 'Dictionary'
	   let keys = sort(keys(val))
	else 
	   call base#warn({ 
	   	\	"text" : "Input parameter is not hash!",
	   	\	"prefix" : "(base#varhash#keys) ",
	   	\	})
	endif

	return keys
	
endfunction

function! base#varhash#new (...)
	let hashname = get(a:000,0,'')
	let value = get(a:000,1,{})
	let hash = value

	call base#varset(hashname,value)
	return value

endfunction

function! base#varhash#extend (...)
	let hashname = get(a:000,0,'')
	let exd      = get(a:000,1,{})

	let hash     = base#varget(hashname,{})
	call extend(hash,exd)

	call base#varset(hashname,hash)

endfunction

"base#varhash#get ()
"base#varhash#get (hash)
"base#varhash#get (hash,key)
"base#varhash#get (hash,key,default)

function! base#varhash#get (...)

	let hashname = get(a:000,0,'')
	let val = base#varget(hashname,{})

	if a:0 == 1
			return val
	endif

	let key      = get(a:000,1,'')
	let default  = get(a:000,2,{})

	if !strlen(hashname) | return default | endif

	if base#type(val) == "Dictionary"
		let hash = val
		if strlen(key)
			return get(hash,key,default)
		else 
			return default
		endif
	endif

	return default

endfunction

function! base#varhash#haskey (...)
	let hash={}
	let key=''
	if a:0
		let hashname = a:1
		if a:0 == 2
			let key = a:2
		endif
	endif

	let hash = base#varhash#get(hashname)
	if has_key(hash,key)
		return 1
	else 
		return 0
	endif

endfunction
