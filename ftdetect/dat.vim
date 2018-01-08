
au BufRead,BufNewFile *.i.dat		set filetype=idat

if exists("b:idephp_did_ftplugin_html") | finish | endif
let b:idephp_did_ftplugin_html=1

let plg      = 'idephp'

call idephp#buf#maps('html')

