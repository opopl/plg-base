
function! base#comps#bufact (...)	
	let ft = get(a:000,0,&ft)

	let comps = base#varget('comps_BufAct_' . ft,[])
	call extend(comps, base#comps#bufact_common() )

	if exists("b:scp_data")
		call extend(comps, base#varget('comps_scp_bufact',[]) )
	endif

	if exists("b:db_info")
	  let c_db = base#varget('comps_db_info',[])
	  call extend(comps,c_db)
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

	if has('win32')
		call extend(comps,base#varget('comps_common_bufact_win32',[]))
	elseif has('unix')
		call extend(comps,base#varget('comps_common_bufact_unix',[]))
	endif

	if exists("b:url")
		call extend(comps,[ 'url_load_src' ])
	endif

	return comps
endfunction
