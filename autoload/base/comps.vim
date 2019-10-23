
function! base#comps#bufact (...)	
	let ft = get(a:000,0,&ft)

	let comps = base#varget('comps_BufAct_' . ft,[])
	call extend(comps, base#comps#bufact_common() )

	return comps
endfunction

function! base#comps#bufact_scp (...)	
	let comps = base#varget('comps_scp_bufact',[])

	return comps
endfunction

function! base#comps#bufact_common (...)	
	let ft = get(a:000,0,&ft)

	let comps = base#varget('comps_common_bufact',[])

	return comps
endfunction
