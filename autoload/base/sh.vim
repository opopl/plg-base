"
" let sh = '$vim/str/b:a/  $vim/eval/b:file/'
" echo base#sh#expand({ 'sh' : sh, 'vars' : { 'a' : 3 }})
"
" call tree
"   called by
"     base#util#itm#x_sh
"
"{
function! base#sh#expand (...)
  let ref  = get(a:000,0,{})

  let sh   = get(ref,'sh','')
  let vars = get(ref,'vars',{})

	let out = base#varget('sysout',[])

python3 << eof
import vim
import re

import Base.Util as util

vars_ = vim.eval('vars') or {}
sh_   = vim.eval('sh')

# inject vars into vim variables
#for v in vars_:
#	m = re.match('^@',v)
#	if not m:
#		continue
#	vim.command(f'let ')

def ev_(m):
  w = {}
  for k in util.qw('expr mode'):
    v = m.group(k).strip()
    w[k] = v

  if w['expr'] in vars_:
    w['expr'] = vars_.get(w['expr'])

  val = ''
  try:
    if w['mode'] in ['eval']: 
	    val = vim.eval(w['expr'])
    elif w['mode'] in ['str']:
      val = w['expr']
  except vim.error as e:
    print(e)

  return val

delim_ = '/'

pat_ = rf'\$vim{delim_}(?P<mode>(\w+)){delim_}(?P<expr>[^{delim_}]*){delim_}'
she_ = re.sub(pat_,ev_,sh_)
eof
  " expanded
  let she = py3eval('she_')
  return she

endfunction
"} end: 
