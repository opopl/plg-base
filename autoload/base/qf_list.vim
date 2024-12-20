
function! base#qf_list#set (...)
  let ref = get(a:000,0,{})

  let arr = get(ref,'arr',[])

  let list = []
  for a in arr
    let item = { 'text' : a }
    call add(list,item)
  endfor

  call setqflist(list)
  
endfunction

function! base#qf_list#maps ()
  let mp = {
          \  'q'    : 'quit'                ,
          \  ';cc'  : 'cclose'              ,
          \  '<F4>' : 'cclose'              ,
          \ }
  return mp
endfunction

function! base#qf_list#open ()
  botright copen

  let mp = base#qf_list#maps()
  call base#buf#map_add(mp)

  call base#qf_list#statusline ()
endfunction

function! base#qf_list#statusline ()
  let mp = base#qf_list#maps()

  let str = ''

  let sa = []
  for [k,v] in items(mp)
    call add(sa, printf('%s - %s', k, v ))
  endfor
  let str = join(sa, ' , ')

  let str = printf('[%s]',str)
  let str = escape(str,' ')
  exe 'setlocal statusline='.str

endfunction

function! base#qf_list#close ()
  cclose
endfunction
