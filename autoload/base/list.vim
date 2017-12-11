

"a-b - elements of a than are not in b
"
function! base#list#minus (a,b)
	let a=a:a
	let b=a:b
	let kb={}

	for i in b
		let kb[i]=1
	endfor

	let res=[]
	for i in a
		if !exists('kb[i]')
			call add(res,i)
		endif
	endfor

	return res
endf	

function! base#list#unshift (list,element)
	let nlist=[]
	call add(nlist,a:element)
	call extend(nlist,a:list)
	return nlist
endf	

fun! base#list#has(list,element)
	return base#inlist(a:element,a:list)
endfun

fun! base#list#matched(list,pat)
	let list = copy(a:list)
	let m = filter(list,'v:val =~ a:pat')
	return m
endfun

fun! base#list#contains_matches(list,pat)
	let matched = base#list#matched(a:list,a:pat)
	return ( len(matched) ) ? 1 : 0
endfun

function! base#list#convert_to_vim(list,varname)
	let vc=[]
	call add(vc,"let ".a:varname.'= [')
	let list=[]
	for l in copy(a:list)
		let l = "\\ '".l."',"
		call add(list,l)
	endfor
	call extend(vc,list)
	call add(vc," \\ ]")

	return vc
endfun



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
 
