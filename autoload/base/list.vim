

function! base#list#add (ref,...)
        
 if a:0
   let items=a:000
 endif

 let ref=a:ref

 let opts={
        \ 'uniq' : 0,
        \ 'sort' : 0,
        \ }

 if base#type(ref) == 'String'
    let listname=ref

 elseif base#type(ref) == 'Dictionary'
    let listname=ref.list
    for [k,v] in items(ref)
        let opts[k]=v
    endfor

    if has_key(opts,'item')
      let items=[ opts.item ]
    elseif has_key(opts,'items')
      let items=opts.items
    endif

 endif

 let list=[]

 for item in items
    if base#type(item) == 'String'
      call add(list,item)
    elseif base#type(item) == 'List'
      call extend(list,item)
    endif
 endfor

 let eva=[]

 call add(eva,"if exists('" . listname . "')")
 call add(eva,' call extend(' . listname . ', list)'     )
 call add(eva,'else')
 call add(eva,' let ' . listname . '=list'  )
 call add(eva,'endif')
 call add(eva,' ')

 if opts.sort
    call add(eva,'let ' . listname . '=sort(' . listname . ')' )
 endif

 if opts.uniq
   call add(eva,'let ' . listname . '=base#uniq(' . listname . ')' )
 endif

 exe join(eva,"\n")

endfun
 
