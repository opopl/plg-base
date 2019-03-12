
let comps = base#varget('comps_BufAct_tags',[])
call add(comps,'stat')

let b:comps_BufAct = comps

if exists("b:did_base_tags_ftplugin")
  finish
endif
let b:did_base_tags_ftplugin = 1

"""ftplugin_base_tags

