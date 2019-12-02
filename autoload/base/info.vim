
function! base#info#dbext ()
	let varnames = base#varget('varnames_dbext',[])

	let lines = []

	for varname in varnames
		let val = base#value#var(varname)
		let a = varname .' => '.val
		call add(lines,a)
	endfor

	call base#buf#open_split({ 'lines' : lines })
	
endfunction

function! base#info#topics ()
	let topics = base#varget('info_topics',[])
	let topics = sort(topics)
	return topics
endfunction

function! base#info#rtp ()
	let rtp_a = split(&rtp,",")
	
	let ii = []
	call add(ii,'&rtp:')
	call extend(ii,base#map#add_tabs(rtp_a,1))
	
	call base#buf#open_split({ 'lines' : ii })
endfunction

function! base#info#plugins ()
	let plugins = base#plugins()
	
	let ii = []
	call add(ii,'PLUGINS:')
	call extend(ii,base#map#add_tabs(plugins,1))
	call base#buf#open_split({ 'lines' : ii })
endfunction

