function! base#rtp#add_plugin(plg)

	let plgdir = base#catpath('plg', a:plg )

	let prf={ 'func' : 'base#rtp#add_plugin', 'plugin' : 'base' }
	call base#log([
		\	'Adding plugin:' . a:plg,
		\	],prf)

	let dirs=[ plgdir, base#file#catfile([ plgdir , 'after' ]) ]

	let rtp = []
	for dir in dirs 
		if isdirectory(dir)
			call add(rtp,dir)
		endif
	endfor

	let rtp = base#uniq(rtp)
	for dir in rtp
		exe 'set rtp+=' . dir
	endfor

	let sdir = base#file#catfile([ plgdir, 'data', 'snippets' ])
	call base#snip#add_dir(sdir)

endf



function! base#rtp#uniq()

	let rtp = split(&rtp,",")
	let n = []
	call map(rtp,'base#file#ossep(v:val)')

	let rtp = base#uniq(rtp)

	exe 'set rtp=' . join(rtp,",")

endf

" BaseAct rtp_helptags
"
function! base#rtp#helptags(...)
	let list = base#rtp#list()

	for rtp in list
		let docdir=base#file#catfile([ rtp , 'doc' ])
		call base#vim#helptags({ 'dir' : docdir})
	endfor

endf

function! base#rtp#list(...)
	return split(&rtp,',')
endf

"call base#rtp#list_opensplit(...)

function! base#rtp#list_opensplit(...)
	let list = base#rtp#list()
	call base#buf#open_split({ 'lines' : list })
endf

function! base#rtp#update(...)
	call base#init#plugins()

	for plg in base#varget('plugins',[])
		call base#rtp#add_plugin(plg)
	endfor

	for dir in split(&rtp,',')
		let docdir=base#file#catfile([ dir , 'doc' ])

		call base#vim#helptags({ 'dir' : docdir})
	endfor

	call base#rtp#uniq()

endf
