
function! base#view#lines (...)

		let lines = a:1
	
    split
    enew

    call append(0,lines)

    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nomodifiable

endfunction

function! base#view#files (...)
	let ref=get(a:000,0,{})

	let files = get(ref,'files',[])

	let title = get(ref,'title','')
	let dir   = get(ref,'dir','')

  let info = []
  for file in files
    call add(info,[ file ])
  endfor

  let lines = [ title ]
  call extend(lines,get(ref,'lines_before_table',[]))

  call extend(lines, pymy#data#tabulate({
    \ 'data'    : info,
    \ 'headers' : get(ref,'table_headers',['file']),
    \ }))
  
  let s:obj = {  'dir' : dir }
  function! s:obj.init (...) dict
    let r = {
        \  'dir'  : self.dir,
        \  'mode' : 'num',
        \  }
    call base#varset('ref_vis_act_open_file',r)

    resize 999
    vnoremap <silent><buffer> v :'<,'>call base#vis_act#open_file()<CR>
    
  endfunction
  
  let Fc = s:obj.init

  let stl_add = [
    \ '[ %3* v - view %0* ]'
    \ ]

  call base#buf#open_split({ 
    \ 'lines'   : lines,
    \ 'stl_add' : stl_add,
    \ 'Fc'      : Fc,
    \ })

endfunction
