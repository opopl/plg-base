
let b:comps_BufAct = base#varget('comps_BufAct_html',[])
if exists("b:did_html_vim_ftplugin")
  finish
endif
let b:did_html_vim_ftplugin = 1

let b:finfo   = base#getfileinfo()
let b:dirname = get(b:finfo,'dirname','')
