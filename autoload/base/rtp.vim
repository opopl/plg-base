function! base#rtp#add_plugin(plg)

	let plg = base#catpath('plg', a:plg )

	let dirs=[ plg, base#file#catfile([ plg , 'after' ]) ]

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

	"let dirs=	get

	for plg in base#varget('plugins',[])
		call base#rtp#add_plugin(plg)
	endfor

	for dir in split(&rtp,',')
		let docdir=base#file#catfile([ dir , 'doc' ])
		
		if ( isdirectory(docdir) )

			let ff = base#find({ "dirs" : [docdir] })

			if len(ff)
				call base#vim#helptags({ 'dir' : docdir})
			endif
		endif
	endfor

	call base#rtp#uniq()

endf
