

"
function! base#file#qw(...)
	let str = a:1
	let qw = base#qw(str)

	let f = base#file#catfile(qw)

	return f
endfunction

function! base#file#exists(file)

endfunction

function! base#file#copy(old,new)
	if !filereadable(a:old)
		call base#warn({ 'text' : 'Old file does not exist:'."\n\t" . a:old })
		return 
	endif
	let cmd = ''
	if has('win32')
		let cmd = 'copy ' . '"'.a:old.'"' . ' ' . '"'.a:new.'"'
	else
		let cmd = 'cp ' . '"'.a:old.'"' . ' ' . '"'.a:new.'"'
	endif

	if !strlen(cmd)
		return 
	endif

	let ok = base#sys({ "cmds" : [cmd]})

	return ok

endfunction

function! base#file#move(old,new)
	if !filereadable(a:old)
		call base#warn({ 'text' : 'Old file does not exist:'."\n\t" . a:old })
		return 
	endif
	let cmd = ''
	if has('win32')
		let cmd = 'move ' . '"'.a:old.'"' . ' ' . '"'.a:new.'"'
	else
		let cmd = 'mv ' . '"'.a:old.'"' . ' ' . '"'.a:new.'"'
	endif

	if !strlen(cmd)
		return 
	endif

	let ok = base#sys({ "cmds" : [cmd]})

	return ok

endfunction

function! base#file#delete( ... )
	let ref  = get(a:000,0,{})
	let file = get(ref,'file','')

	let ok = 0

	if !filereadable(file) 
			let prf={ 'prf' : 'base#file#delete' }
			call base#log([
				\	'file does not exist',
				\	],prf)
			return
	endif

	call delete(file)
	if !filereadable(file) 
		let ok = 1
	endif

	return ok

endfunction


" base#file#catfile([ 'a', 'b'])
" base#file#catfile({ 'a' : [ 'a', 'b' ]})

function! base#file#catfile( ... )
	
	if ! a:0 | return '' | endif

	if type(a:1) == type([])
			let pieces = a:1
			let sep = has('win32') ? '\' : '/'
			let sep = get(a:000,1,sep)

			let pieces = map(pieces,'base#file#catfile(v:val,sep)')

			let path = join(pieces,sep)
			let path = base#file#std(path,sep)

			return path 

	elseif type(a:1) == type({})
			let dirs=a:1

			let d=[]
			for id in keys(dirs)
					unlet d
					let d=dirs[id]
					if type(d) == type([])
						let dirs[id]=base#file#catfile(d)
					endif
			endfor

			return dirs

	elseif type(a:1) == type('')
			let path = a:1

			return path
	endif

endf

function! base#file#lines(file)
	let file = a:file
	let lines=[]

	if !filereadable(file)
		return lines
	endif

	let lines = readfile(file)
	return lines
endf

function! base#file#tempname(...)
	let ref      = get(a:000,0,{})

	let template = get(ref,'template','')
	let suffix   = get(ref,'suffix','')
	let dir      = get(ref,'dir','')

	let tmpname  = ''
perl << eof
	use File::Temp qw(tempfile);
	use File::Path qw(mkpath);

	my $template = VimVar('template') || 'XXXXXX';
	my $suffix   = VimVar('suffix') || '';

	my $dir = VimVar('dir') || catfile($ENV{appdata},qw(plg base base_file_tempname ));
	mkpath $dir unless -d $dir;

	my $tmp;
  (undef, $tmp) = tempfile($template, OPEN => 0, DIR => $dir, SUFFIX => $suffix);

	VimLet('tmpname',$tmp);
eof
	return tmpname
endf

function! base#file#stat(file,...)
	let file = a:file
	let st = {}
python << eof

import vim
import os

file = vim.eval('file')
stat = os.stat(file)

st = { 
	'mtime' : stat.st_mtime ,
	'ctime' : stat.st_ctime ,
	'size'  : stat.st_size ,
}

for k in st.keys():
	v = st.get(k)
	cmd = "call extend(st,{ " + "'" + k +"'" + ' : ' + "'" + str(v) +"'" + "})"
	vim.command(cmd)
	
eof
	return st

endf

function! base#file#mtime(file,...)
	let file = a:file
	let mtime = 0
python << eof
import vim
import os
import datetime

file = vim.eval('file')
stat = os.stat(file)
mtime = stat.mtime 

vim.command('let mtime=' + str(mtime) )
	
eof
	return mtime 

endf

function! base#file#size(file,...)
	let file = a:file
	let size = 0
python << eof
import vim
import os
import datetime

file = vim.eval('file')
stat = os.stat(file)
size = stat.st_size 

vim.command('let size=' + str(size) )
	
eof
	return size

endf

function! base#file#tmp()
    let tmp      = tempname()
    let tmp_dir  = expand(fnamemodify(tmp,':p:h'))
    let tmp_name = fnamemodify(tmp,':t')
    
    let tmp = base#file#catfile([ tmp_dir, tmp_name ])
		return tmp
endf

function! base#file#basename(file)
	let file  = a:file
	let bname = fnamemodify(file,':p:t')
	return bname
endf

function! base#file#write_lines(...)	
	let ref = get(a:000,0,{})

	let lines  = get(ref,'lines',[])
	let file   = get(ref,'file','')
	let prompt = get(ref,'prompt',0)
	let mode   = get(ref,'mode','rewrite')

	if prompt
		let yn = input('(base#file#write_lines) Write to file? (1/0):',0)
		if !yn | return | endif
	endif

	let dirname = fnamemodify(file,':p:h')

	if !isdirectory(dirname)
		call base#mkdir(dirname)
	endif

	let prf = { 'plugin' : 'base', 'func' : 'base#file#write_lines', 'prf' : '' }
	call base#log([
			\	'writing to file: ' . file,
			\	],prf)

	" -1 fail code for writefile()
	let ec        = -1

	let filelines = []

	try
		if ( (mode == 'append') && (filereadable(file) ) )
			let filelines = readfile(file)
		endif

		call extend(filelines,lines)
		let ec = writefile(filelines,file)
	catch 
		call base#warn({
			\	'text' : 'errors while writing to file!',
			\	},prf)
	finally
		if filereadable(file)
			call base#log([
				\	'file exists.',
				\	],prf)
		endif

		call base#log([
				\	'writefile() exit code: '.ec,
				\	'	(-1 - FAIL, 0 - OK)',
				\	],prf)
	endtry



endf

function! base#file#front(file)

	let spt = base#file#ossplit( a:file )
	let front = spt[0]

	return front

endf

function! base#file#sep ()
	if has('win32')
		let sep = '\'
	else
		let sep = '/'
	endif
	return sep
	
endfunction

function! base#file#parts( filename,... )
	let filename = a:filename

	let sep      = base#file#sep()
	let filename = base#file#std(filename)
	let parts    = split(filename,sep)

	return parts

endfunction

function! base#file#std( filename,... )
	let fname = a:filename

	if a:0
		let sep = a:1
	else
		let sep = base#file#sep()
	endif

	let fname = base#file#ossep(fname)

	let pref = matchstr(fname,'\zs'.escape(sep,'\').'*\ze')
	let pref = strlen(pref) ? sep : ''

	let pc = split(fname,sep)
	call filter(pc,'v:val != ""')

	let rpc = reverse(copy(pc))

	let rm = 0
	let npc=[]
	while len(rpc)
		let p = remove(rpc, 0)
		if p == ".." 
			let rm+=1
		else
			if ( rm > 0 )
				let rm-=1
			else
				if strlen(p)
					call add(npc,p)
				endif
			endif
		endif
	endw
	let pc = reverse(npc)

	let fname = join(pc,sep)
	let fname = pref . fname
	return fname

endf


function! base#file#unix2win( filename )
	let fname = a:filename

	if has('win32')
		return substitute(fname,'/','\','g')
	endif

	return fname

endf

function! base#file#ossep( filename )
	let fname = a:filename

	if has('win32')
		return base#file#unix2win(fname) 
	else
		return base#file#win2unix(fname) 
	endif

	return base#file#std(fname)

endf

function! base#file#win2unix( filename )

	let s = a:filename

	if has('win32')
		let s = substitute(s,'[\\]\+','\\','g')
		let s = substitute(s,'\\','/','g')
	endif

	return s

endf

function! base#file#ossplit( filename )
	let fname = a:filename

	let sep = base#file#sep()

	let spt = []

	let start = matchstr(fname,'^\zs'.escape(sep,'\/').'*\ze')

	if strlen(start)
		call add( spt, start )
	endif

	call extend( spt,split(fname,sep) )

	return spt

endf


" check if dirs or files share a common root with out
" 	a  => a/b/c
" 	b  => a/b/c/d
"
" call base#file#commonroot ([ dir1, dir2 ])
"
function! base#file#commonroot (...)
	let dirs = a:1

	let root = ''

	let splitdirs = {}
	let i  = 0

	for dir in dirs
		let dir          = base#file#std(dir)
		let dir          = base#file#ossep(dir)
		let splitdirs[i] = base#file#ossplit(dir)

		let i+=1
	endfor
	let ilast = i-1

	let s    = copy(splitdirs[0])
	let list = base#listnewinc(1,ilast,1)

	let si = 0
	let fin = 0
	
	let r = []

	while len(s)

		let c = remove(s,0)
		for i in list
			let other = splitdirs[i]
			if ! exists('other[si]') 
				let fin = 1 
				break
			endif

			if ( c != other[si] )
				let fin = 1
				break
			endif

			if fin | break | endif
		endfor

		if fin | break | endif

		let si+=1
		call add(r,c)
	endw

	let root = base#file#catfile(r)

	return root
	
endfunction

"echo base#file#reldir('c:\doc\photos','c:\')

function! base#file#reldir (dir,root)
	let dir  = a:dir
	let root = a:root

	let root = base#file#std(root)
	let dir = base#file#std(dir)

	let reldir = base#file#removeroot (dir,root)

	if reldir == dir
		return ''
	endif
	return reldir

endfunction

function! base#file#removeroot (dir,root)
	let dir  = base#file#std(a:dir)
	let root = base#file#std(a:root)
	let sep  = base#file#sep()

	let sep  = escape(sep,'\')
	let root = escape(root,'\')

	let pat = '^'.root.sep.'\(.*\)'

	let rm = substitute(dir,pat,'\1','g')
	return rm

endfunction
