
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
 
 return base#omni#basecomplete(a:findstart,a:base,base#var('omni_comps'))

endfun

function! base#omni#selectcompletion (...)

 set omnifunc=base#omni#complete

 let funopts='replace'

  if a:0
    let opt=a:1
    let opts=split(opt,',')

    if len(opts) > 1 
	  call base#varset('omni_comps',[])
      for opt in opts
        call base#omni#selectcompletion(opt,'add')
      endfor
      return
    endif
  else
    let opt='pap_tex_papers'

    let listcomps=base#varget('omni_compoptions_list',[])

    let liststr = join(listcomps,"\n")
    let dialog  = "Available omni completions are: " . "\n"
    let dialog .= base#createprompt(liststr, 1, "\n") . "\n"
    let dialog .= "Choose omni completion by number: " . "\n"

    let opt     = base#choosefromprompt(dialog,liststr,"\n",'pap_tex_papers')
    echo "Selected: " . opt
  endif

  if a:0 == 2
    let funopts=a:2
  endif

  let comps=[]

  let omni_comps=[]

  if base#varexists('omni_compnames')
  		let omni_compnames=base#var('omni_compnames')
  else
  		let omni_compnames=[]
  endif

  let h = base#var('omni_comp_arrays')

  if has_key(h,opt)
	let v = h[opt]
    exe 'let comps='.v
  "elseif index(g:F_tex_omnifuncs,opt) >= 0 
  elseif opt == '_smart_tex' 
	let a = ['tex_latex_commands_text']
    exe 'let omni_comps=a'
    set omnifunc=OMNI_COMPLETE_TEX
	let omni_compnames = [opt]
  endif

  if !base#varexists('omni_comps')
  	call base#var('omni_comps',[])
  endif

  if len(comps)
    if funopts == 'replace'
		let omni_compnames = [opt]
		let omni_comps = comps

    elseif funopts == 'add'
      	call extend(omni_comps, comps )
      	
		call add(omni_compnames, opt )
    endif
  endif

 let omni_comps=sort(base#uniq(omni_comps))
 call base#var('omni_comps',omni_comps)

 call base#var('omni_compnames',omni_compnames)
endf

function! base#omni#init ()

	let h    = base#var('omni_comp_arrays')
	let list = sort(keys(h))
	call base#var('omni_compoptions_list',list)
	
endfunction
