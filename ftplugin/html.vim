

if exists("b:did_html_vim_ftplugin")
  finish
endif
let b:did_html_vim_ftplugin = 1

let b:finfo   = base#getfileinfo()
let b:dirname = get(b:finfo,'dirname','')

let b:cr      = base#file#commonroot([ b:dirname, plgdir ] )

let b:is_inews_local = ( b:cr == base#path('inews_local') )
