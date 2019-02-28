
function! base#url#struct (url)
	let url = a:url
	let struct = {}
python << eof

import vim
import re

import os
import posixpath

from urlparse import urlparse
from collections import deque


url = vim.eval('url')
o = urlparse(url)

host=o.netloc
host=re.sub(r':(\d+)$','',host)

path = o.path
basename = posixpath.basename(path)

cmds=deque([])
cmds.append('call extend(struct,{ "path" :' + '"' + path +'"' + '})' )
cmds.append('call extend(struct,{ "host" :' + '"' + host +'"' + '})' )
cmds.append('call extend(struct,{ "port" :' + '"' + str(o.port) +'"' + '})' )
cmds.append('call extend(struct,{ "fragment" :' + '"' + o.fragment +'"' + '})' )
cmds.append('call extend(struct,{ "query" :' + '"' + o.query +'"' + '})' )
cmds.append('call extend(struct,{ "basename" :' + '"' + basename +'"' + '})' )

for cmd in cmds:
	vim.command(cmd)

eof
	return struct

	
endfunction
