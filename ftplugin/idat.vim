
let b:comps_BufAct = base#varget('comps_BufAct_idat',[])

if exists("b:base_did_ftplugin_idat") | finish | endif
let b:base_did_ftplugin_idat=1

call base#buf#start()

"""base_ftplugin_idat

let pall     = base#varget('plugins_all',[])

for plg in pall
	let plgdir   = base#qw#catpath('plg',plg)
	
	let b:cr      = base#file#commonroot([ b:dirname, plgdir ] )
	let b:belongs = ( b:cr == plgdir )
	
	if b:belongs
		 let b:plg=plg
		 call base#tg#add('plg_'.plg)
		 StatusLine plg
		 break
	endif
endfor
