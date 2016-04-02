
fun! base#omni#basecomplete(findstart,base, arr)

 "let words=map(a:arr,'toupper(v:val)')
 let words = a:arr
 let base  = a:base

    if a:findstart
      " locate the start of the word
      let line = getline('.')
      let start = col('.') - 1

      while start > 0 && line[start - 1] =~ '\a'
        let start -= 1
      endwhile

      return start
    else
      " find months matching with "a:base"
      let res = []

      for m in words
        if toupper(m) =~ '^' . toupper(base)
          call add(res, m)
        endif
      endfor

      return res
    endif

endfun

fun! base#omni#complete(findstart,base)
 
 return base#omni#basecomplete(a:findstart,a:base,base#vars('omni_comps'))

endfun

function! base#omni#selectcompletion (...)

 set omnifunc=base#omni#complete

 let funopts='replace'

  if a:0
    let opt=a:1
    let opts=split(opt,',')

    if len(opts) > 1 
	  call base#var('omni_comps',[])
      for opt in opts
        call base#omni#selectcompletion(opt,'add')
      endfor
      return
    endif
  else
    let opt='pap_tex_papers'

	call F_VarUpdate('OMNI_CompOptions_List')

    let listcomps=g:OMNI_CompOptions_List

    let liststr=join(listcomps,"\n")
    let dialog="Available omni completions are: " . "\n"
    let dialog.=F_CreatePrompt(liststr, 1, "\n") . "\n"
    let dialog.="Choose omni completion by number: " . "\n"

    let opt= F_ChooseFromPrompt(dialog,liststr,"\n",'pap_tex_papers')
    echo "Selected: " . opt
  endif

  if a:0 == 2
    let funopts=a:2
  endif

  let comps=[]

  if ! exists('g:OMNI_CompNames')
    let g:OMNI_CompNames=[]
  endif

  if has_key(g:OMNI_COMP_ARRAYS,opt)
    call F_VarCheckExist(g:OMNI_COMP_ARRAYS[opt])
    exe 'let comps= ' . g:OMNI_COMP_ARRAYS[opt] 
  elseif index(g:F_tex_omnifuncs,opt) >= 0 
  elseif opt == '_smart_tex' 
    exe 'let g:OMNI_COMPS= ' . g:OMNI_COMP_ARRAYS['tex_latex_commands_text'] 
    set omnifunc=OMNI_COMPLETE_TEX
    let g:OMNI_CompNames=[ opt ]
  endif

"""change
  "inoremap<silent> LOP <esc>:OMNIFUNC pap_tex_papers<CR>
  "inoremap<silent> VPROJ <esc>:OMNIFUNC projs<CR>
  
  if ! exists("g:OMNI_COMPS")
    let g:OMNI_COMPS=[]
  endif

  if len(comps)
    if funopts == 'replace'
      let g:OMNI_COMPS= comps 
      let g:OMNI_CompNames=[ opt ]
    elseif funopts == 'add'
      call extend(g:OMNI_COMPS, comps )
      call add(g:OMNI_CompNames, opt )
    endif
  endif

 let g:OMNI_COMPS=sort(F_uniq(g:OMNI_COMPS))

endf
