
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

function! base#varhash#get (...)

	let hashname = get(a:000,0,'')
	let key      = get(a:000,1,'')
	let default  = get(a:000,2,{})

	if !strlen(hashname) | return default | endif

	let val = base#varget(hashname,{})

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
