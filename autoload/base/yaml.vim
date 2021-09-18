
function! base#yaml#dump (...)
  if !has('python3') | return | endif

  let data = get(a:000,0,{})

python3 << eof
import vim
import yaml
#from ruamel import yaml

data = vim.eval('data')

y = yaml.dump(data, allow_unicode = True)
eof

  let y = py3eval('y')
  return y
  
endfunction

function! base#yaml#parse_fs (...)
  if !has('python3') | return | endif

  let ref  = get(a:000,0,{})

  let file  = get(ref,'file','')
  let lines = readfile(file)
  let ytxt  = join(lines, "\n")

python3 << eof
import vim,os,sys
import yaml
#from ruamel import yaml
#
file = vim.eval('file')
ytxt = vim.eval('ytxt')

data = {}
data = yaml.safe_load(ytxt)

eof
  let data = py3eval('data')
  return data

endfunction

function! base#yaml#dump_fs (...)
  if !has('python3') | return | endif

  let ref  = get(a:000,0,{})

  let data = get(ref,'data',{})
  let file = get(ref,'file','')
python3 << eof
import vim
import yaml
#from ruamel import yaml

data = vim.eval('data')
file = vim.eval('file')

y = yaml.dump(data, allow_unicode = True)

with open(file, 'w', encoding='utf8') as f:
  f.write(y)
eof

endfunction
