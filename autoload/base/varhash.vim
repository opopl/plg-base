
function! base#varhash#keys (var)
	let val = base#var(a:var)

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
	let hash={}
	let key=''
	if a:0
		let hashname = a:1
		if a:0 == 2
			let key = a:2
		endif
	endif

	let val = base#var(hashname)
	if base#type(val) == "List"
		let hash = val
		if key
			return hash[key]
		else 
			return hash
		endif
	endif

	return hash

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
