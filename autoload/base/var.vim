
function! base#var#update (varname,...)
  let varname = a:varname

  let msg = [ 'var => ' . a:varname ]
  let prf = { 
    \ 'plugin' : 'base',
    \ 'func'   : 'base#var#update' }
  call base#log(msg, prf)

  let opts_update = get(a:000,0,{})

  let datfiles = base#datafiles()
  let datlist  = base#datlist()

  let types = {
      \ 'dict'      : 'Dictionary',
      \ 'list'      : 'List',
      \ 'listlines' : 'ListLines',
      \ }

"""var_update_fileids
  if varname == 'fileids'
    let files = base#exefile#files()

    let fileids = sort(keys(files))
    call base#varset('exefileids',fileids)

"""var_update_buf_vars
  elseif varname == 'buf_vars'

    """ list of buffer variables for this buffer
    let bbv = base#buf#vars()
    let buf_vars = base#varget('buf_vars',{})
    call extend(buf_vars,{ b:bufnr : bbv })
    call base#varset('buf_vars', buf_vars )

  elseif varname == 'datlist'
    let datlist = base#sqlite#datlist()
    call base#varset('datlist',datlist)

  elseif varname == 'datfiles'
    let datfiles = base#sqlite#datfiles()
    call base#varset('datfiles',datfiles)

"""var_update_plugins_all
  elseif varname == 'plugins_all'
    let var = base#find({ 
      \ "dirids"      : ['plg'],
      \ "relpath"     : 1,
      \ "subdirs"     : 0,
      \ "dirs_only"   : 1,
      \ "pat_exclude" : '^.git',
      \ })
    call base#varset(varname,var)

  elseif base#inlist(varname,datlist)
    let datfile = get(datfiles,varname,'')
    let dfu     = base#file#win2unix(datfile)

    let typedir = fnamemodify(dfu,':p:h:t')
    let type    = get(types,typedir,'')

    let data = base#readdatfile({ 
        \   "file" : datfile ,
        \   "type" : type ,
        \   })

    call base#varset(varname,data)
  else
    return
  endif

  let prf = { 'func' : 'base#var#update', 'plugin' : 'base' }
  call base#log([
    \ 'updated: ' . varname,
    \ ],prf)
  return

endfunction

function! base#var#dump(varname)
    let val       = base#varget(a:varname)
    let dump      = base#dump(val)
    return dump
endfunction

function! base#var#dump_lines(varname)
    let dump = base#var#dump(a:varname)
    return split(dump, "\n" )
endfunction

function! base#var#dump_split (varname)
    let dump = base#var#dump(a:varname)
    
    let dumplines = split(dump,"\n")
    let sz   = len(dumplines)
    let last = sz-1

    let a = []
    call add(a,'if exists("w") | unlet w | endif')
    call add(a,' ')
    call add(a,'let w=' . base#list#get(dumplines,0))

    if last > 0
      let b = base#list#get(dumplines,'1:'.last)
      call extend(a,map(b,"'\t\\ ' . v:val"))
    endif

    call base#buf#open_split({ 'lines' : a })
  
endfunction

function! base#var#to_xml (...)
  let var_name  = get(a:000,0,'')

  let vars = base#vars()

  let var_list = []
  if !strlen(var_name)
    let var_list = base#varlist()
  else
    call add(var_list,var_name)
  endif

  "echo vars

  " return value
  let xml = ''

  if has('python3')
python3 << eof

import vim
import re
import lxml.etree as et

var_list = vim.eval('var_list')
vars     = vim.eval('vars')

#legal_chars = string.ascii_lowercase + string.digits + "!#$%&'*+-.^_`|~:"
#print('[%s]+' % re.escape(legal_chars))

vars_p = {}
#print(var_list)

for var_name in var_list:
  vars_p.update({ var_name : vars.get(var_name) })

  #print(vars_p)

def data2xml(d, name='data'):
    r = et.Element(name)
    return et.tostring(buildxml(r, d), pretty_print=True)

def buildxml(r, d):
    if isinstance(d, dict):
        r.set('type','dict')
        for k, v in d.items():
            #s = et.SubElement(r, k)
            s = et.SubElement(r, 'var')
            s.set('name',k)
            buildxml(s, v)
    elif isinstance(d, tuple) or isinstance(d, list):
        r.set('type','list')
        for v in d:
            s = et.SubElement(r, 'i')
            buildxml(s, v)
    elif isinstance(d, str):
        r.text = re.escape(d)
    else:
        r.text = re.escape(str(d))
    return r

vars_xml = data2xml(vars_p, name='vars')
  
eof
    let decl = '<?xml version="1.0" encoding="UTF-8"?>'
    let xml = py3eval('vars_xml')
    let xml = decl."\n".xml
  endif

  return xml
endfunction

function! base#var#dump_xml (...)
  let var_name  = get(a:000,0,'')

  let xml = base#var#to_xml(var_name)

  if strlen(xml)
    call base#buf#open_split({ 
      \ 'text'     : xml,
      \ 'cmds_pre' : ['set ft=xml'],
      \ })
  endif

endfunction

if 0
  called by:
    base#plg#loadvars_xml
endif

function! base#var#update_from_xml (...)
  let ref = get(a:000,0,{})

  let xml_files = get(ref,'xml_files',[])
  let xml_file  = get(ref,'xml_file','')

  if len(xml_files)
    for xml_file in xml_files
      call base#var#update_from_xml({ 'xml_file' : xml_file })
    endfor
  endif

python3 << eof
import vim
from xml.etree import ElementTree
from xml.etree.ElementTree import (
  tostring
)

xml_file = vim.eval('xml_file')
plg      = vim.eval('plg')

vars = {}

with open(xml_file, 'rt') as f:
  tree = ElementTree.parse(f)
  for var_node in tree.findall('.//var'):
      v_name = var_node.attrib.get('name')
      if v_name != 'base' : 
        v_name = plg + '_' + v_name
      v_type      = var_node.attrib.get('type')
      v_entry_tag = var_node.attrib.get('entry_tag')
      if v_type == 'dict' :
        var = {}
        for entry in tree.findall( './/' + v_entry_tag ):
          key   = entry.attrib.get('key')
          value = entry.attrib.get('value')
          if value is None:
            value = entry.text
          if value is not None:
            value_split = map(lambda x: x.strip(), value.split("\n") )
            value       = "\n".join(value_split)
            var.update({ key : value })
        if len(var.keys()):
          vars.update({ v_name : var })
eof
  let vars = py3eval('vars')
  for [ k, v ] in items(vars)
    call base#varset(k,v)
  endfor

endfunction
