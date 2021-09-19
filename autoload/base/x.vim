
function! base#x#list (...)
  let expr = get(a:000,0,{})
  let opts = get(a:000,1,{})

  let sep = get(opts,'sep',' ')

  let lst = []
  let tp = base#type(expr)

  let r = { 'sep' : sep }
  if tp  == 'String'
    let lst = base#string#split_trim(expr,r)
    
  elseif base#inlist(tp,base#qw('Number Float'))
    let expr = string(expr)
    let lst = base#x#list(expr,opts)

  elseif tp == 'List'
    let lst = expr

  elseif tp == 'Dictionary'
    
  endif
  return lst
  
endfunction

if 0
	let d = { 'a' : { 'b' : 2 }}
	let val = base#x#getpath(d,'a.b',3)
	echo val
endif

function! base#x#getpath (ref,path,default)
  let ref     = a:ref
  let path    = a:path
  let default = a:default
python3 << eof
import vim
import Base.Util as util
ref_     = vim.eval('ref') or {}
path_    = vim.eval('path') or ''
default_ = vim.eval('default')

val = util.get( ref_, path_, default_ )
eof
	let val = py3eval('val')
	return val

endfunction

" v:none, '' => default
function! base#x#get (ref,key,default)
  let ref     = a:ref
  let key     = a:key
  let default = a:default

  let val = ''
  let okv = 1

  let tp = base#type(ref)

  if base#inlist(tp,base#qw('Dictionary List'))
    let val = get(ref,key,default)
  
    let okv = okv && (type(val) != type(v:none))
    let okv = okv && (type(val) != type('') || len(val))
  else
    let okv = 0
  endif

  return okv ? val : default

endfunction
