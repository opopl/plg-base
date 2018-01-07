
function! base#act#list_vim_commands ()

	let coms = base#vim#list_coms ()
	echo coms
	
endfunction

function! base#act#envvar_open_split (...)
	let envv = input('Env variable:','','environment')
	call base#envvar_open_split(envv)

endfunction

""look opts_BaseAct.i.dat
function! base#act#open_split_list (...)
	 
	let listvar = input('List variable:','','custom,base#complete#varlist_list')
	let list    = base#varget(listvar,[])

	call base#list#open_split(list)

endfunction
