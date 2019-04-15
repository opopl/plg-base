

let s:comps = base#comps#bufact('html') 

if exists("b:db_info")
	let c_db = base#varget('comps_db_info',[])
	call extend(s:comps,c_db)
endif

let b:comps_BufAct = s:comps 
	
if exists("b:did_html_vim_ftplugin")
  finish
endif
let b:did_html_vim_ftplugin = 1

let b:finfo   = base#getfileinfo()
let b:dirname = get(b:finfo,'dirname','')
