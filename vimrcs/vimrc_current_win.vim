set nocompatible

if has('win32')
	set gfn=Lucida_Console:h15:cANSI
else
	set gfn=Monospace\ 20
endif
colors koehler

let s:opt = 'rtp_base'
let s:opt = 'simple'
let s:opt = 'all'


"""""""""""""""""""""""""
"""opt_all
if s:opt == 'all'
"""""""""""""""""""""""""
	set rtp+=$VIMRUNTIME/plg/vim_prettyprint
	set rtp+=$VIMRUNTIME/plg/mru
	"set rtp+=$VIMRUNTIME/plg/nerdtree
	"set rtp+=$VIMRUNTIME/plg/nerdcommenter
	"set rtp+=$VIMRUNTIME/plg/tagbar

	set rtp+=$VIMRUNTIME/plg/base
	set rtp+=$VIMRUNTIME/plg/ap
	call ap#startup()
	call base#init()
	TgAdd plg_base
	TgAdd plg_ap
"""""""""""""""""""""""""
"""opt_simple
elseif s:opt == 'simple'
"""""""""""""""""""""""""
	set rtp+=$VIMRUNTIME/plg/ap
	set rtp+=$VIMRUNTIME/plg/mru
	set rtp+=$VIMRUNTIME/plg/nerdtree
	set rtp+=$VIMRUNTIME/plg/nerdcommenter
	set rtp+=$VIMRUNTIME/plg/tagbar
	set rtp+=$VIMRUNTIME/plg/vim_prettyprint
	call ap#startup()

"""""""""""""""""""""""""
elseif s:opt == 'rtp_base'
"""""""""""""""""""""""""
	set rtp+=$VIMRUNTIME/plg/base
endif




