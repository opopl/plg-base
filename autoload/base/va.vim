
function! base#va#add (listname,element)
		let listname  = a:listname
		let element   = a:element

		let list = base#varget(listname,[])
		call add(list,element)
		call base#varset(listname,list)
	
endfunction

function! base#va#extend (listname,elements)
		let listname = a:listname
		let elements = a:elements

		let list = base#varget(listname,[])
		call extend(list,elements)
		call base#varset(listname,list)
	
endfunction
