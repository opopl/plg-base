
function! base#git#update (...)
endfunction

function! base#git#needs2commit (...)
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
