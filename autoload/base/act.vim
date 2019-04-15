
function! base#act#list_vim_commands ()

	let coms = base#vim#list_coms ()
	echo coms
	
endfunction

function! base#act#envvar_open_split (...)
	let envv = input('Env variable:','','environment')
	call base#envvar_open_split(envv)

endfunction

function! base#act#file_view (...)
	let fileid = get(a:000,0,'')

	while !strlen(fileid)
		let msg    = 'fileid: '
		let fileid = base#input_we(msg,'',{
			\ 'complete' : 'custom,base#complete#db_fileids' })
	endw

	let file = base#db#file_path(fileid)

	call base#fileopen({ 'files': [file] })
endfunction


function! base#act#async_run (...)
	let cmd = get(a:000,0,'')

	let env = {}
	function env.get(temp_file) dict
			let h = ''
			"if self.return_code == 0
				" use tiny split window height on success
				"let h = 1
			"endif
			" open the file in a split
			exec h . "split " . a:temp_file
			
			if filereadable(a:temp_file)
				let out = readfile(a:temp_file)
				call base#varset('last_async_output',out)
			endif
			" remove boring build output
			"%s/^\[xslt\].*$/
			" go back to the previous window
			wincmd p
	endfunction
	
	" tab_restore prevents interruption when the task completes.
	" All provided asynchandlers already use tab_restore.
	call asynccommand#run(cmd, asynccommand#tab_restore(env))

endfunction

function! base#act#paths_to_db (...)
	call base#paths_to_db()
endfunction

function! base#act#paths_from_db (...)
	call base#paths_from_db()
endfunction

function! base#act#dict_view (...)
	let dicts = split(&dict,',')

	for dict in dicts
		if filereadable(dict)
			call base#fileopen({'files':[dict]})
		endif
	endfor

endfunction

function! base#act#perl_Vim_Plg_Base (...)

perl << eof
	use Vim::Plg::Base;
	use Vim::Perl qw(:funcs :vars);

	our $plgbase ||=	Vim::Base::Plg->new;

	VimCmd(qq{ let sub=input('Vim::Base::Plg method:','','custom,base#complete#perl_Vim_Plg_Base' ) });
	my $sub=VimVar('sub');

	$plgbase->$sub();
eof

endfunction


function! base#act#rtp_helptags (...)
	call base#rtp#helptags()

endfunction

""look opts_BaseAct.i.dat
function! base#act#open_split_list (...)
	 
	let listvar = input('List variable:','','custom,base#complete#varlist_list')
	let list    = base#varget(listvar,[])

	call base#list#open_split(list)

endfunction
