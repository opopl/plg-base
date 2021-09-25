
"{
" input controller

if 0
  usage
    let lst = projs#author#ids()
    let r = { 
      \ 'list'  : lst,
      \ 'thing' : 'author_id',
      \ }

    let value = base#inpx#ctl(r) 
endif

fun! base#inpx#ctl(...)
  let ref = get(a:000,0,{})

  let prefix = ''
  let prefix = base#x#get(ref,'prefix',prefix)

  let delim = repeat('.',50)
  let delim = base#x#get(ref,'delim',delim)

  " e.g. author_id, tag
  let thing  = base#x#get(ref,'thing','')

  " message to always appear at the top
  let header  = base#x#get(ref,'header',[])

  let lst   = base#x#get(ref,'list',[])
  let lst   = copy(lst)

  let msg     = printf('%s %s: ',prefix,thing)

  let msg     = base#x#get(ref,'msg',msg)
  let default = base#x#get(ref,'default','')

  let msg_things_del = 'delete: '
  let msg_head_cmds_a = [
      \ '',
      \ 'Commands:',
      \ '   ; - skip',
      \ '   . - finish',
      \ '   , - delete selected',
      \ '   @ - complete',
      \ ]

  let msg_top_a = []

  if len(header)
    call extend(msg_top_a,[delim])
    call extend(msg_top_a,header)
    call extend(msg_top_a,[delim])
  endif

  call extend(msg_top_a,msg_head_cmds_a)

  let msg_top = len(msg_top_a) ? "\n" . join(msg_top_a, "\n") : ''

  let msg_head = msg_top 

  " final string with things chosen, comma-separated list
  let things = ''
  let things_selected = []

  let keep = 1
  while keep
    let cnt = 0

    let cmpl = ''
    call base#varset('this',lst)

    let tgs = input(msg_head . "\n" . msg,'','custom,base#complete#this')
    let tgs = base#trim(tgs)

    let things_s = tgs

    " finish
    if things_s == '.'
       let tgs = join(things_selected, ',')
       break

    " skip and continue
    elseif things_s[-1:-1] == ';'
       let cnt = 1

    " completions 
    elseif things_s[-1:-1] == '@'
       let word = substitute(copy(things_s),'^\(.*\)@$','\1','g')
       let flt_a = base#map#filter(lst,{ 'regex' : '^'.word })
       if len(flt_a)
         let flt_s = join(base#map#add_spaces(flt_a,2),"\n")
         call base#varset('this',flt_a)
         let matches_s = input(flt_s . "\n" . 'select matches: ','','custom,base#complete#this')
       endif

    " delete selected and continue
    elseif things_s =~ ',\s*$'
       let cnt = 1

       call base#varset('this',things_selected)

       " things to delete
       let things_del = input(msg_head . msg_things_del,'','custom,base#complete#this')
       let things_del_a = split(things_del,',')

       let n = []
       for tg in things_selected
         if !base#inlist(tg,things_del_a)
           call add(n,tg)
         else
           call add(lst,tg)
         endif
       endfor

       call sort(lst)

       let things_selected = n
       call sort(things_selected)

     " add and continue
    else
       let cnt = 1

       let things_a = split(things_s,',')
       let lst = base#list#rm(lst,things_a)
       for tg in things_a
         if !base#inlist(tg,things_selected)
           call add(things_selected,tg)
         endif
       endfor

       call sort(things_selected)

    endif

    let msg_head = msg_top 
       \ . "\n" . printf('%s(s) selected:',thing )
       \ . "\n" . join(base#map#add_spaces(things_selected,2), "\n") . "\n"

    if cnt | continue | endif
    break
  endw

  return tgs


endfun
"}
