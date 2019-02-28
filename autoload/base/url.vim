
function! base#url#struct (url)
	let url = a:url
	let struct = {}
python << eof

import vim
import re

from urlparse import urlparse
from collections import deque

url = vim.eval('url')
o = urlparse(url)

host=o.netloc
host=re.sub(r':(\d+)$','',host)

cmds=deque([])
cmds.append('call extend(struct,{ "path" :' + '"' + o.path +'"' + '})' )
cmds.append('call extend(struct,{ "host" :' + '"' + host +'"' + '})' )
cmds.append('call extend(struct,{ "port" :' + '"' + str(o.port) +'"' + '})' )
cmds.append('call extend(struct,{ "fragment" :' + '"' + o.fragment +'"' + '})' )
cmds.append('call extend(struct,{ "query" :' + '"' + o.query +'"' + '})' )

for cmd in cmds:
	vim.command(cmd)

eof
	return struct

	
endfunction
