
"{
" input controller
fun! base#inpx#ctl(msg,default,...)
  let ref = get(a:000,0,{})

  let prefix = get(ref,'prefix',prefix)
  let thing  = get(ref,'thing','')

  let list   = get(ref,'list',[])

  let msg = printf('%s %s: ',prefix,'things')
  let msg = get(ref,'msg','')

  let msg_things_del = 'delete: '
  let msg_head = ''
  let msg_head_base_a = [
      \ '',
      \ 'Commands:',
      \ '   ; - skip',
      \ '   . - finish',
      \ '   , - delete selected',
      \ ]
  let msg_head_base = join(msg_head_base_a, "\n")

  " final string with things chosen, comma-separated list
  let things = ''
  let things_selected = []

  let keep = 1
  while keep
    let cnt = 0

    let cmpl = ''
    call base#varset('this',list)

    let tgs = input(msg_head . msg,'','custom,base#complete#this')

    let things_s = tgs

    " finish
    if things_s =~ '\.\s*$'
       let tgs = join(things_selected, ',')
       break

    " skip and continue
    elseif things_s =~ ';\s*$'
       let cnt = 1

    " delete selected and continue
    elseif things_s =~ ',\s*$'
       call base#varset('this',things_selected)

       let things_del = input(msg_head . msg_things_del,'','custom,base#complete#this')
       let things_del_a = split(things_del,',')

       let n = []
       for thing in things_selected
         if !base#inlist(thing,things_del_a)
           call add(n,thing)
         endif
       endfor

       let things_selected = n
       call sort(things_selected)

       let msg_head = msg_head_base 
          \ . "\n" . 'things selected:' 
          \ . "\n" . join(things_selected, "\n") . "\n"

       let cnt = 1

     " add and continue
    else
       let things_a = split(things_s,',')
       for thing in things_a
         if !base#inlist(thing,things_selected)
           call add(things_selected,thing)
         endif
       endfor

       call sort(things_selected)
       let things_n = ''
       for tg in things_selected
         let things_n .= "  " . tg . "\n"
       endfor

       let msg_head = msg_head_base 
          \ . "\n" . 'things selected:' 
          \ . "\n" . things_n
       let cnt = 1
    endif

    if cnt 
      continue
    endif

    break
  endw

  return tgs


endfun
"}
