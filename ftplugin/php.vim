
let b:comps_BufAct = []

let comps = []
call extend(comps,base#varget('comps_BufAct_php',[]))
"call extend(comps,base#varget('comps_BufAct_html',[]))

let b:comps_BufAct = comps

if exists("b:did_php_vim_ftplugin")
  finish
endif
let b:did_php_vim_ftplugin = 1


