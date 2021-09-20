
"{
function! base#util#itm#expand#str (...)
  let ref = get(a:000,0,{})

  let str     = base#x#get(ref,'str','')

  let itm_    = base#x#get(ref,'%itm',{})
  let dd_vars = base#x#get(ref,'%vars',{})

  let str = base#sh#expand({ 
    \ 'sh'   : str,
    \ 'vars' : dd_vars,
    \ })

python3 << eof
import vim
import re
import Base.Util as util

str_     = vim.eval('str') or ''
itm_     = vim.eval('itm_') or {}
dd_vars_ = vim.eval('dd_vars') or {}

def ev_itm(m):
  path = m.group('path').strip()
  val = ''
  if path:
    val = util.get(itm_,path,'')
  return val

def ev_var(m):
  varname = m.group('varname').strip()
  val = ''
  if path:
    val = util.get(dd_vars_,varname,'')
  return val

delim_ = '/'

pat_ = rf'%itm{delim_}(?P<path>[^{delim_}]*){delim_}'
str_ = re.sub(pat_,ev_itm,str_)

pat_ = rf'%var{delim_}(?P<varname>[^{delim_}]*){delim_}'
str_ = re.sub(pat_,ev_var,str_)
eof
  " expanded
  let str = py3eval('str_')
  return str

endfunction
"} end: 
"
function! base#util#itm#expand#list (...)
  let ref = get(a:000,0,{})

  let lst     = base#x#get(ref,'list',[])
  let lst  = copy(lst)

  let itm_    = base#x#get(ref,'%itm',{})
  let dd_vars = base#x#get(ref,'%vars',{})
  let new = []

  for a in lst
    let r = {
       \ '%itm'  : itm_,
       \ '%vars' : dd_vars
       \ }
    call extend(r,{ 'data' : a })
    let a =  base#util#itm#expand#data (r)
    call add(new,a)
  endfor
  return new

endfunction

function! base#util#itm#expand#data (...)
  let ref = get(a:000,0,{})

  let data    = base#x#get(ref,'data',{})

  let itm_    = base#x#get(ref,'%itm',{})
  let dd_vars = base#x#get(ref,'%vars',{})

  let r = {
     \ '%itm'  : itm_,
     \ '%vars' : dd_vars,
     \ }

  if base#type(data) == 'String'
    call extend(r,{ 'str' : data })
    let data = base#util#itm#expand#str (r)
    
  elseif base#type(data) == 'List'
    call extend(r,{ 'list' : data })
    let data = base#util#itm#expand#list (r)
    
  elseif base#type(data) == 'Dictionary'
    call extend(r,{ 'dict' : data })
    let data = base#util#itm#expand#dict (r)
    
  endif

  return data

endfunction


function! base#util#itm#expand#dict (...)
  let ref = get(a:000,0,{})

  let dict    = base#x#get(ref,'dict',{})
  let dict    = copy(dict)

  let itm_    = base#x#get(ref,'%itm',{})
  let dd_vars = base#x#get(ref,'%vars',{})

  for [k,v] in items(dict)
    let r = {
       \ '%itm'  : itm_,
       \ '%vars' : dd_vars
       \ }

    call extend(r,{ 'data' : v })
    let v = base#util#itm#expand#data (r)

    call extend(dict,{ k : v })
  endfor

  return dict

endfunction
