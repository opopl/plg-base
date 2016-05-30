

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