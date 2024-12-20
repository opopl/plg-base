

"a-b - elements of a than are not in b
"
function! base#list#minus (a,b)
  let a=a:a
  let b=a:b
  let kb={}

  for i in b
    let kb[i]=1
  endfor

  let res=[]
  for i in a
    if !exists('kb[i]')
      call add(res,i)
    endif
  endfor

  return res
endf  

function! base#list#to_xml (...)
  let ref = get(a:000,0,{})

  let list     = get(ref,'list',[])
  let item_tag = get(ref,'item_tag','item')
  let top_tag  = get(ref,'top_tag','top')

  let var_type  = get(ref,'var_type','dict')
  let var_name  = get(ref,'var_name','')
  let var_attr  = get(ref,'var_attr',{})

python3 << eof
import vim
import xml.etree.ElementTree as et

list     = vim.eval('list')
item_tag = vim.eval('item_tag')
top_tag  = vim.eval('top_tag')

var_type  = vim.eval('var_type')
var_name  = vim.eval('var_name')
var_attr  = vim.eval('var_attr')

from xml.etree import ElementTree
from xml.dom import minidom

from xml.etree.ElementTree import (
    Element, SubElement, Comment, tostring,
)

def prettify(elem):
    """Return a pretty-printed XML string for the Element.
    """
    rough_string = ElementTree.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")

list.sort()

n_top = Element(top_tag)
n_var = SubElement(n_top,'var')

if var_type:
  n_var.set('type', var_type)

if var_name:
  n_var.set('name', var_name)

if var_attr:
  for k,v in var_attr.items():
    n_var.set(k, v)

for item in list:
  n_item = SubElement(n_var, item_tag )
  n_item.set('key', item)
  n_item.text = ' '

res = prettify(n_top)

eof
  let res = py3eval('res')
  return res
endf  

function! base#list#unshift (list,element)
  let nlist=[]
  call add(nlist,a:element)
  call extend(nlist,a:list)
  return nlist
endf  

fun! base#list#has(list,element)
  return base#inlist(a:element,a:list)
endfun

fun! base#list#matched(list,pat)
  let list = copy(a:list)
  let m = filter(list,'v:val =~ a:pat')
  return m
endfun

" remove elements from a list
fun! base#list#rm(...)
  let lst = get(a:000,0,[])
  let elems = get(a:000,1,[])

  if base#type(elems) == 'String'
    let elems = [ elems ]
  elseif base#type(elems) != 'List'
    return lst
  endif

  let new = []
  for itm in lst
    if ! base#inlist(itm,elems)
      call add(new,itm)
    endif
  endfor

  return new

endfun

fun! base#list#contains_matches(list,pat)
  let matched = base#list#matched(a:list,a:pat)
  return ( len(matched) ) ? 1 : 0
endfun

function! base#list#convert_to_vim(list,varname)
  let vc=[]
  call add(vc,"let ".a:varname.'= [')
  let list=[]
  for l in copy(a:list)
    let l = "\\ '".l."',"
    call add(list,l)
  endfor
  call extend(vc,list)
  call add(vc," \\ ]")

  return vc
endfun

function! base#list#new (...)
  let start = get(a:000,0,'')
  let end   = get(a:000,1,'')
  let inc   = get(a:000,2,1)

  let is_num = 1
  let is_num = is_num && (type(start) == type(0))
  let is_num = is_num && (type(end) == type(0))
  let is_num = is_num && (type(inc) == type(0))

  let is_str = 1
  let is_str = is_str && !is_num
  let is_str = is_str && (type(start) == type(''))
  let is_str = is_str && (type(end) == type(''))

  if is_num
    let list = base#listnewinc(start,end,inc)
  elseif is_str
perl << eof
  use Vim::Perl qw(VimVar VimLet);

  my $start = VimVar('start');
  my $end   = VimVar('end');
  my @list = ( $start .. $end );

  VimLet('list',[@list]);
eof

"---------------------------------
"python3 << eof
"import vim

"start = vim.eval('start')
"end   = vim.eval('end')
"list  = []

"for i in range( ord(start), ord(end) + 1 ):
  "list.append(chr(i))
  
"eof
    "let list = py3eval('list')
"---------------------------------
    
  endif
    return list

endfun

function! base#list#get (arr,ind)
   let sz   = len(a:arr)
   let last = sz-1

   if type(a:ind) == type(0)
      return get(a:arr,a:ind,'')     
   elseif type(a:ind) == type([])
      let r=[]
      for i in a:ind
         if type(i)==type(0)
            call add(r,base#list#get(a:arr,i))     
         endif
      endfor
      return r
   elseif type(a:ind) == type('')
      let ind_split=split(a:ind,",")

      let res = []
      if len(ind_split) > 1
         for ind in ind_split
            if exists("a") | unlet a | endif

            let a = base#list#get(a:arr,ind)
            if  (type(a) == type('')) || (type(a) == type(0))
              call add(res,a)
            elseif  (type(a) == type([]))
              call extend(res,a)
            endif
         endfor
         return res
      endif

      let pats      = { 
        \ 'range'  : '^\(-\d\+\|\d\+\):\(-\d\+\|\d\+\)$',
        \ 'single' : '^\(-\d\+\|\d\+\)$',
        \  }

      let list_single = base#string#matchlist(a:ind,pats.single)
      if len(list_single)
         let [ind]=map(base#list#get(list_single,[0]),'str2nr(v:val)')
         return  base#list#get(a:arr,ind)
      endif

      let list_range = base#string#matchlist(a:ind,pats.range)
      if len(list_range)
         let [start,end] = map(base#list#get(list_range,[0,1]),'str2nr(v:val)')
         if end > start
            let inc = 1
         else
            let inc = -1
         endif
         let ids = base#listnewinc(start,end,inc)

         return base#list#get(a:arr,ids)
      endif
   endif
endfun

function! base#list#open_split (list)
   split
   enew
   setlocal buftype=nofile
   call append('.',a:list)

endfun


function! base#list#rmwh (list)
  let list=a:list
  call map(list,'base#rmwh(v:val)')
  return list
endfun

function! base#list#add_heads_letters (ref,...)
  let ref         = a:ref

  let list        = get(ref,'list',[])
  let startletter = get(ref,'start','a')
  let endletter   = get(ref,'end','z')

  let slist=[]
  for l in list
    if type(l)==type('')
      call add(slist,l)
    endif
  endfor

perl << eof
  my $s     = VimVar('startletter');
  my $e     = VimVar('endletter');
  my @heads = ( $s .. $e );

  my @list = VimVar('slist');
  my @nlist;
  my $head=shift @heads;
  foreach my $l (@list) {
    local $_=$l;
    /^\S/ && do {
      s/^/$head /g;
      $head=shift @heads;
    };
    VIM::Msg($l);
    push @nlist,$_;
  }
  VimLet('list',[@nlist]);
eof

  "return list

endfun

function! base#list#add (ref,...)
 let ref = a:ref
        
 if a:0
   let items = a:000
 endif

 let opts={
        \ 'uniq' : 0,
        \ 'sort' : 0,
        \ }

 if base#type(ref) == 'String'
    let listname = ref

 elseif base#type(ref) == 'Dictionary'
    let listname = ref.list
    for [k,v] in items(ref)
        let opts[k]=v
    endfor

    if has_key(opts,'item')
      let items=[ opts.item ]
    elseif has_key(opts,'items')
      let items=opts.items
    endif

 endif

 let list=[]

 for item in items

    if base#type(item) == 'List'
      call extend(list,item)
    else
      call add(list,item)
    endif
 endfor

 let eva=[]

 call add(eva,"if exists('" . listname . "')")
 call add(eva,' call extend(' . listname . ', list)'     )
 call add(eva,'else')
 call add(eva,' let ' . listname . '=list'  )
 call add(eva,'endif')
 call add(eva,' ')

 if opts.sort
    call add(eva,'let ' . listname . '=sort(' . listname . ')' )
 endif

 if opts.uniq
   call add(eva,'let ' . listname . '=base#uniq(' . listname . ')' )
 endif

 let evas = join(eva,"\n")

 exe evas

endfun
 
