
if exists("b:idephp_did_ftplugin_idat") | finish | endif
let b:idephp_did_ftplugin_idat=1

call base#buf#start()

let pall     = base#varget('plugins_all',[])

for plg in pall
	let plgdir   = base#qw#catpath('plg',plg)
	
	let b:cr      = base#file#commonroot([ b:dirname, plgdir ] )
	let b:belongs = ( b:cr == plgdir )
	
	if b:belongs
		 call base#tg#add('plg_'.plg)
		 StatusLine plg
		 break
	endif
endfor
