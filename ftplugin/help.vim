
let b:comps_BufAct = base#varget('comps_BufAct_help',[])

if exists("b:base_did_ftplugin_help") | finish | endif
let b:base_did_ftplugin_help=1

setlocal iskeyword+=<,>
setlocal iskeyword+=/
setlocal iskeyword+=$
