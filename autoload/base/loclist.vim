
function! base#loclist#open ()
  lopen

  let mp = {
          \  'q'    : 'quit'                ,
          \  ';cc'  : 'lclose'              ,
          \  '<F4>' : 'lclose'              ,
          \ }
  call base#buf#map_add(mp)

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
