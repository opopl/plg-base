
function! base#act#list_vim_commands ()

	let coms = base#vim#list_coms ()
	echo coms
	
endfunction

function! base#act#envvar_open_split (...)
	let envv = input('Env variable:','','environment')
	call base#envvar_open_split(envv)

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
