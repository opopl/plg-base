
let b:comps_BufAct = []

let comps = []
call extend(comps,base#varget('comps_BufAct_html',[]))

let b:comps_BufAct = comps

if exists("b:did_xhtml_vim_ftplugin")
  finish
endif
let b:did_xhtml_vim_ftplugin = 1
