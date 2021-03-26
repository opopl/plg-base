
function! base#url#struct (url)
  let url = a:url
  let struct = {}

  if has('python3')
    let struct = base#url#struct_py(url)
  endif

  return struct
endf

if 0
  call tree
    called by
endif

function! base#url#parse (url,...)
  let url  = a:url

  let opts = get(a:000,0,{})

python3 << eof

import vim
import Base.Util as util

url  = vim.eval('url')
opts = vim.eval('opts')

u = util.url_parse(url,opts)

eof
  let u = py3eval('u')
  return u
endf

function! base#url#struct_py (url)

  let url    = a:url
  let struct = {}
python3 << eof

import vim
import re

import os
import posixpath

from urllib.parse import urlparse

from collections import deque

url = vim.eval('url')
o   = urlparse(url)

host = o.netloc
host = re.sub(r':(\d+)$','',host)

scheme = o.scheme
path   = o.path

if ((host == '') and (scheme == '')):
  scheme = 'http:'
  url = scheme + "//" + url
  o = urlparse(url)

host = o.netloc
host = re.sub(r':(\d+)$','',host)

scheme = o.scheme
path   = o.path

basename = posixpath.basename(path)

cmds = deque([])
cmds.append('call extend(struct,{ "path" :' + '"' + path +'"' + '})' )
cmds.append('call extend(struct,{ "host" :' + '"' + host +'"' + '})' )
cmds.append('call extend(struct,{ "port" :' + '"' + str(o.port) +'"' + '})' )
cmds.append('call extend(struct,{ "fragment" :' + '"' + o.fragment +'"' + '})' )
cmds.append('call extend(struct,{ "query" :' + '"' + o.query +'"' + '})' )
cmds.append('call extend(struct,{ "scheme" :' + '"' + o.scheme +'"' + '})' )
cmds.append('call extend(struct,{ "basename" :' + '"' + basename +'"' + '})' )
cmds.append('call extend(struct,{ "url" :' + '"' + url +'"' + '})' )

for cmd in cmds:
  vim.command(cmd)

eof
  return struct
endfunction

function! base#url#basename (url)
  let url = a:url
  let struct = base#url#struct(url)
  let basename = get(struct,'basename','')
  return basename
endfunction

function! base#url#normalize_htw (url)
  call base#html#htw_init ()
  let url = a:url
perl << eof
  use Vim::Perl qw(VimVar);
  my $url = VimVar('url');
  
  $url = $HTW->url_normalize($url);
  return $url;
eof

endfunction
