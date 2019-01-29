
let b:comps_BufAct = []

let comps = []
call extend(comps,base#varget('comps_BufAct_python',[]))

let b:comps_BufAct = comps

let b:base_did_ftplugin_python=1
if exists("b:base_did_ftplugin_python")
	finish
endif

setlocal ts=2
