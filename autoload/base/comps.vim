
function! base#comps#bufact (...)	
	let ft = get(a:000,0,&ft)

	let comps = base#varget('comps_BufAct_' . ft,[])
	call extend(comps, base#comps#bufact_common() )

	if exists("b:scp_data")
		call extend(comps, base#varget('comps_scp_bufact',[]) )
	endif

	return comps
endfunction

function! base#comps#bufact_scp (...)	
	let comps = base#varget('comps_scp_bufact',[])

	return comps
endfunction

function! base#comps#bufact_common (...)	
	let ft = get(a:000,0,&ft)

	let comps = base#varget('comps_common_bufact',[])

	if exists("b:url")
		call extend(comps,[ 'url_load_src' ])
	endif

	return comps
endfunction
