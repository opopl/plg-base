
function! base#complete#hist#BaseVimCom (...)
	let hist=base#varget('hist_cmds',{})
	let ch = get(hist,'BaseVimCom',[])

	let comps=ch
	return join(comps,"\n")
endfunction

function! base#complete#hist#BaseVimFun (...)
	let hist=base#varget('hist_cmds',{})
	let ch = get(hist,'BaseVimFun',[])

	let comps=ch
	call extend(comps,base#varget('opts_BaseVimFun',[]))
	return join(comps,"\n")
endfunction
