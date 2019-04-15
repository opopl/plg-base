
let b:comps_BufAct = base#varget('comps_BufAct_sql',[])
let b:comps_BufAct = base#comps#bufact('sql') 

if exists("b:did_sql_vim_ftplugin")
  finish
endif
let b:did_sql_vim_ftplugin = 1

