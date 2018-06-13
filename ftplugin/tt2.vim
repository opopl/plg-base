
if exists("b:base_did_ftplugin_tt2") | finish | endif
let b:base_did_ftplugin_tt2=1

let b:comps_BufAct = base#varget('comps_BufAct_tt2',[])

setlocal iskeyword+=<,>
setlocal iskeyword+=/

setlocal smartindent
setlocal autoindent
