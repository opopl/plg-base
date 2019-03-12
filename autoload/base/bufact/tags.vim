"""BufAct_lynx_dump_split
function! base#bufact#tags#list_of_tags ()
	call base#buf#start()

	let pat = input('pattern for tags:','')

	let tags = []
python << eof
import vim,re
from collections import deque

file = vim.eval('b:file')
pat = vim.eval('pat')

regexp = re.compile('^(\S+)\s+')
re_pat = re.compile(pat)

tags = deque([])

with open(file) as f:
	for line in f:
		m = re.search(regexp, line)
		if m is not None:
			append=1
			tag = m.group(0)
			if re_pat:
				m = re.search(re_pat, tag)
				if m is None:
					append=0
			if append:
				tags.append(tag)

print tags
eof
endfunction

