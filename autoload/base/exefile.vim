

function! base#exefile#view (...)
	let fileid = get(a:000,0,'')

	if !strlen(fileid)
		let fileid = input('Fileid:','','custom,base#complete#exefileids')
	endif

	let fp = base#exefile#path(fileid)

	if base#type(fp)=='List'
		let files = fp

	elseif base#type(fp)=='String'
		let files = [ fp ]

	endif

	call base#fileopen({ 'files' : files })

endfunction

function! base#exefile#add (...)
  if ! exists("s:exefiles") | let s:exefiles={} | endif

	let opt = get(a:000,0,'')

	if opt == 'thisfile'
		let filepath     = expand('%:p')
		let bname        = expand('%:p:t')

		let fileid = substitute(bname,'\.','_','g')

		let fileid = input('Suggested fileid:',fileid,'custom,base#complete#exefileids')

		let lines=[]

		call add(lines,		'-----------------------')
		call add(lines,		 'File data to be added:')
		call add(lines,		 '   '.fileid)
		call add(lines,		 '   '.filepath)
		call add(lines,		 '-----------------------')

		let text = join(lines,"\n")."\n"

		call base#echo({ 'text' : text, 'prefix' : '' })

		let cnt = input('Continue? (1/0):',1)

		if cnt
			call base#exefile#set({ fileid : filepath })
		endif
	endif
	
endfunction

function! base#exefile#files ()
  if ! exists("s:exefiles") | let s:exefiles={} | endif
	return s:exefiles
endfunction

function! base#exefile#set (...)
	let ref=get(a:000,0,{})

  if !exists("s:exefiles") | let s:exefiles={} | endif

	call base#init#sqlite()

	let pc = base#pcname()

  for [ fileid, file ] in items(ref) 
		 if type(file) == type('') && !filereadable(file)
				continue
		 endif

     let e = { fileid : file }
     call extend(s:exefiles,e)

		 if has('perl')
perl << eof
		use Vim::Perl qw(VimVar);

		my $file   = VimVar('file');
		my $fileid = VimVar('fileid');
		my $pc     = VimVar('pc');

		my $a = $plgbase
			->dbh
			->selectall_arrayref('select fileid from exefiles where fileid=?',undef,$fileid);
		unless(@$a) {
			$plgbase
				->db_prepare('insert into exefiles ( fileid, file, pc ) values(?,?,?)')
				->db_execute($fileid,$file,$pc);
		}


eof
		 endif

		 call base#log(['base#exefile#set: fileid='.fileid])
		 call base#log(['base#exefile#set: file  ='.file])

  endfor

  call base#varset('exefiles',s:exefiles)
  call base#varset('exefileids',sort(keys(s:exefiles)))

	call base#var#update('fileids')

endfun

"call base#exefile#run (fileid)
"call base#exefile#run (fileid,args)
"call base#exefile#run (fileid,args,idnum)
"
"call base#exefile#run (fileid,args,0)
"call base#exefile#run (fileid,args,1)

"call base#exefile#run ({ 
"		\	'id'    : fileid,
"		\	'args'  : args,
"		\	'idnum' : idnum
"		\	})
"

function! base#exefile#run (...)
	let ref = get(a:000,0,{})

	if type(ref)==type({})
	elseif type(ref)==type('')
		let fileid = get(a:000,0,'')
		let args   = get(a:000,1,'')
		let idnum  = get(a:000,2,0)

		let files  = get(s:exefiles,fileid,[])

		call base#exefile#run({ 
			\	'id'       : fileid,
			\	'args'     : args,
			\	'idnum' 	 : idnum	})
		return 1
	else 
		return 0
	endif

	let fileid = get(ref,'id','')
	let args   = get(ref,'args',[])
	let args_s = join(args,' ')
	let idnum  = get(ref,'idnum',0)

	let file 	 = base#exefile#path(fileid,idnum)
	let cmd    = '"'.file.'"' . ' ' . args_s

	let cmds   = []
	call add(cmds,cmd)

	call base#sys({ 
			\	"cmds"         : cmds,
			\	"split_output" : get(ref,'split_output',0),
			\	"skip_errors"  : 1,
			\	})

endfunction

function! base#exefile#run_prompt (...)
	let fileid = get(a:000,0,'')
	let f      = base#exefile#path(fileid)

	let idnum=0
	if type(f)==type([])
		let idnum=input('Idnum:',0)
	endif
	let file = base#exefile#path(fileid,idnum)

	let args_s=input('Args:','')
	let args_a=split(args_s,' ')

	call base#exefile#run({ 
		\	'id'           : fileid,
		\	'args'         : args_a,
		\	'idnum'        : idnum ,
		\	'split_output' : 1,
		\	})

endf

fun! base#exefile#showfiles(...)
  if ! exists("s:exefiles") | let s:exefiles={} | endif

	echo s:exefiles
endfun

fun! base#exefile#echo_fpath(fpath)
	let l=[]

	if type(a:fpath)==type('')
		call add(l,'Exe full path: ' . a:fpath)
		call add(l,'Exe exists:    ' . ( filereadable(a:fpath)  ? 'YES' : 'NO' ))

	elseif type(a:fpath)==type([])
		let num=1
		for f in a:fpath
			call add(l,'EXE '.num)
			call extend(l,map(base#exefile#echo_fpath(f),"substitute(v:val,'^','\\t','g')"))
			let num+=1
		endfor

	endif

	return l
endfun

fun! base#exefile#echo(...)
  let aa     = a:000
  let fileid = get(aa,0,'')

	if !strlen(fileid)
		call base#exefile#showfiles()
	endif

  let fpath  = base#exefile#path(fileid)

	let l=[]
	call add(l,'      ')
	call add(l,'Exe id:        ' . fileid)
	call extend(l,base#exefile#echo_fpath(fpath))
	call add(l,'      ')

	call base#buf#open_split({ 'lines' : l})
endf

"echo base#exefile#path('perl')
"echo base#exefile#path('perl',0)
"echo base#exefile#path('perl',1)

fun! base#exefile#path(...)
  let aa=a:000

  if ! exists("s:exefiles") | let s:exefiles={} | endif

  let fileid = get(aa,0,'')
  let index  = get(aa,1,'')

  let fpath  = get(s:exefiles,fileid,'')

  if type(fpath) == type([])
     if len(index)
       let p = get(fpath,index,'')
       return p
     endif
  endif

  return fpath
endf

