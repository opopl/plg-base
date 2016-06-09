
function! base#git#update (...)
endfunction

function! base#git#info(...)
   let aa=a:000

   let key = get(aa,0,'')
   let def = get(aa,1,'')

   let info = base#varget('gitinfo',{})
   let val  = get(info,key,'')

   if !len(val) | return def | endif

   return val
endfunction

function! base#git#modified()
   let m = base#git#info('modified',0)

   return m
endfunction

function! base#git#cmdopts (...)
	let cmdopts = {
		\ 'push'   : "origin master" ,
		\ 'commit' : '-a -m "u"'   ,
		\ 'remote' : '-v'          ,
		\ 'rm'     : '--cached'    ,
		\ 'submodule' : 'update'   ,
		\ }
	return cmdopts
endfunction

"function! base#git#process_out()
"function! base#git#process_out(out)

function! base#git#process_out(ref,...)
   let ref = a:ref

   let aa  = a:000

   let out = base#varget('gitcmd_out',[])
   let cmd = get(ref,'cmd','')
   let out = get(ref,'out',out)

   let gitinfo={
      \ 'modified' : 0,
      \ 'lastcmd'  : cmd,
   \  }
   let cmd = base#rmwh(cmd)
   let cmd = substitute(cmd,'^git\s*','','g')

   let cmds={ 
    \ 'st' : base#qw('st status') 
    \ }

   for lin in out
     if ( lin =~ 'modified:' ) && base#inlist(cmd,cmds.st)
       let gitinfo['modified']=1
     endif
   endfor

   call base#var('gitinfo',gitinfo)
        
endfunction
