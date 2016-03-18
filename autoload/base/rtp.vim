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

function! base#rtp#update()
	call base#initplugins()

	for plg in base#var('plugins')
		call base#rtp#add_plugin(plg)
	endfor

	for dir in split(&rtp,',')
		let docdir=base#file#catfile([ dir , 'doc' ])
		
		if ( isdirectory(docdir) )

			let ff = base#find({ "dirs" : [docdir] })

			if len(ff)
				try
					silent exe 'helptags ' . docdir 
				catch /^Vim(execute):E151/
					echo 'error E151'
				endtry

			endif
		endif
	endfor

	call base#rtp#uniq()

endf
