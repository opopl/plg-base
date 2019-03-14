
function! base#bufact#idat#update_var ()
	call base#buf#start()

	if !exists("b:plg") | return | endif

	let vname = substitute(b:basename,'\.i\.dat$','','g')
	let b:dattype = fnamemodify(b:file,':h:t')

	let kf = vname
	if !( b:plg == 'base')
		let kf = b:plg . '_' . vname
	endif
	
	let t = "datfiles"
	let h = {
		\	"datfile" : b:file,
		\	"key"     : vname,
		\	"keyfull" : kf,
		\	"plugin"  : b:plg,
		\	"type"    : b:dattype,
		\	}
	
	let ref = {
		\ "dbfile" : base#dbfile(),
		\ "i"      : "INSERT OR REPLACE",
		\ "t"      : t,
		\ "h"      : h,
		\ }
		
	call pymy#sqlite#insert_hash(ref)
		
	call base#var#update(vname)
endf	
