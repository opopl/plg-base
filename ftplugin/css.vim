

let b:comps_BufAct = base#varget('comps_BufAct_css',[])
if exists("b:did_css_vim_ftplugin")
  finish
endif
let b:did_css_vim_ftplugin = 1

let b:finfo   = base#getfileinfo()
let b:dirname = get(b:finfo,'dirname','')

let rdir = base#path('inews_local')

let b:cr      = base#file#commonroot([ b:dirname, rdir ] )

let b:is_inews_local = ( b:cr == rdir )


