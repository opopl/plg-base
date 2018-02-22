set nocompatible

set gfn=Lucida_Console:h15:cANSI
colors koehler

set rtp+=$VIMRUNTIME/plg/base
set rtp+=$VIMRUNTIME/plg/ap

call ap#startup()
call base#init()

TgAdd plg_base
TgAdd plg_ap

"
"call base#rtp#update()
"
"PlgRuntime nerdcommenter
"PlgRuntime nerdtree
"PlgRuntime tagbar
"PlgRuntime idephp
"PlgRuntime txtmy
"


