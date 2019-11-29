
"echo base#html#tag('th')
"echo base#html#tag('th','Row')
"echo base#html#tag('th','Row',{2:2})

function! base#html#tag (...)
  let tag = get(a:000,0,'')
  let txt = get(a:000,1,'')
  let attr = get(a:000,2,{})

  let op = '<'.tag

  for [k,v] in items(attr)
      let op = op . ' '. '"'.k.'"='.'"'.v.'"'
  endfor
  let op = op . '>'

  let cl = '</'.tag.'>'
  let s = op.txt.cl

  return s
  
endfunction

function! base#html#strip(string)
  if !has('perl')
    return
  endif

perl << eof
  use utf8;

  use Vim::Perl qw(:funcs :vars);
  use CSS;

  use HTML::Strip;

  my $hs = HTML::Strip->new();

  my $clean_text = $hs->parse( $raw_html );
  $hs->eof;

eof

endfunction

function! base#html#file_info (...)
  let ref = get(a:000,0,{})

  let inf = {}

  let file  = get(ref,'file','')

  let lines = []
  if filereadable(file)
     let lines = readfile(file)
  endif
  let html = join(lines,"\n")
  if !strlen(html) | return {} | endif

  "let h = base#html#headings({ 
    "\ 'file' : file 
    "\ })

  let f =  base#html#xpath({ 
    \ 'file'       : file,
    \ 'xpath'      : '//title/text()',
    \ 'trim'       : 1,
    \ 'skip_empty' : 1,
    \ })

  let title = join(f,'')

  let attr = {}

  let a =  base#html#xpath_attr({ 
    \ 'file'       : file,
    \ 'xpath'      : '//base',
    \ 'attr'       : base#qw('href'),
    \ })
  let base = get(a,0,'')

  call extend(inf,{ 
    \ 'title' : title,
    \ 'base'  : base,
    \ })

  if exists("b:html_info")
    unlet b:html_info
    let b:html_info = inf
  endif

  return inf

endfunction


function! base#html#headings (...)
  let ref   = get(a:000,0,{})

  let lines = get(ref,'lines',[])
  let file  = get(ref,'file','')

  if filereadable(file)
     let lines = readfile(file)
  endif
  let html = join(lines,"\n")

  let h = []
perl << eof
{
  use Base::XML qw( $PARSER $PARSER_OPTS );

  use XML::LibXML;
  use XML::LibXML::PrettyPrint;
  use Encode qw(decode);

  my ($dom, @nodes, $parser);

  $parser = $PARSER || XML::LibXML->new; 

  my $html = VimVar('html');

  my @headnums = (1 .. 5);
  my @heads    = map { "self::h" . $_ } @headnums;
  my $he       = join(' or ',@heads);
  my $xpath    = '//*['.$he.']';

#"//*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5]
#//*[preceding-sibling::h2 = 'Summary' and following-sibling::h2 = 'Location']

  my $xml_libxml_parser_options = $PARSER_OPTS || 
  {
      expand_entities => 0,
      load_ext_dtd    => 1,
      no_blanks       => 0,
      no_cdata        => 0,
      line_numbers    => 1,
  };

  $parser->set_options( %$xml_libxml_parser_options );

  my $inp = {
      string          => decode('utf-8',$html),
      recover         => 1,
      suppress_errors => 1,
  };

  $dom = $parser->load_html(%$inp);

  my $nodelist = $dom->findnodes($xpath);
  my $sub      = sub { local $_ = shift; s/^h(\d+)/$1/g; $_ };
  my @children;
  my @sn;

  my $pp     = XML::LibXML::PrettyPrint->new(indent_string => " ");
  #my $newdom = XML::LibXML::Document->new;

  my %added=();
  my @nodes;
  while( my $node = $nodelist->pop ) {
     unshift @nodes,$node;

     my $lnum = $node->line_number;
     $pp->pretty_print($node);

     my $pos = $nodelist->size;
     my $cmt = "*" x 10 . "pos: ".$pos;
     my $cn  = XML::LibXML::Comment->new($cmt);

     $node->setAttribute('node_lineno',$lnum);
     $node->setAttribute('node_id',$pos);

     my $text = $node->textContent;
     $text=~s/^\s*//g;
     $text=~s/\s*$//g;
     $node->setAttribute('node_text',$text);
     my @textchildren;
     
     for($node->childNodes() ){
        if ($_->nodeType == XML_TEXT_NODE) {
          push @textchildren,$_;
        }
     }
     for my $tchild (@textchildren){
        $node->removeChild($tchild);
     }

     my $prev = $nodelist->get_node($pos);
     last unless $prev;

     my $n_prev = $sub->($prev->nodeName);
     my $n_node = $sub->($node->nodeName);
     my %n=(
        prev => $n_prev,
        node => $n_node,
     );

     unshift @children,{ 
        node => $node,
        num  => $n_node,
        line => $node->line_number,
     };
     
     if ($n{prev} < $n{node}) {
        for my $c (@children){
          my $child      = $c->{node};
          my $child_num  = $c->{num};
          my $child_line = $c->{line};

          my $clone = $child->cloneNode(1);

          next if ($n{prev} > $child_num);

          $prev->addChild($child);
          $added{$child_line}=1;
        }
        @children=();
     }else{
     }
  }

  my @n = map { $added{$_->line_number} ? $_ : () } @nodes;
  my @s = map { $pp->pretty_print($_); $_->toString } @n;

  my $stars = '*' x 50;
  VimMsg([$stars,'Added nodes',$stars]);
  VimLet('h',[@s]);

}
eof

  return h
  
endfunction

function! base#html#text_between_headings (...)
  let ref   = get(a:000,0,{})
  let lines = get(ref,'lines',[])

  let text = []
  let h    = base#html#headings(ref)

  return text

endfunction

function! base#html#css_pretty(string)
  if !has('perl')
    return
  endif
  let css_pp=[]

perl << eof
  use utf8;

  use Vim::Perl qw(:funcs :vars);
  use CSS;

  my $str=VimVar('a:string');
  my $css=CSS->new({ 'adaptor' => 'CSS::Adaptor::Pretty' });

  $css->read_string($str);

  my $o = $css->output();
  my @o = split("\n",$o);

  VimListExtend('css_pp',[@o]);

eof
  return css_pp

endfunction

function! base#html#remove_a(...)
  if !has('perl') | return | endif

  let ref       = get(a:000,0,{})

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])

  if len(htmllines)
    let htmltext=join(htmllines,"\n")
  endif

  let lines = []

perl << eof
  use utf8;
  use Encode;

  use Vim::Perl qw(:funcs :vars);
  use HTML::Work;

  my $html  = VimVar('htmltext');
  
  our $HTW = HTML::Work->new(
    html => $html,
  );
  $HTW->replace_a;
  my $lines = $HTW->htmllines;

  VimListExtend('lines',$lines);

eof
  return lines

endfunction

function! base#html#remove_a_libxml(...)
  if !has('perl') | return | endif

  let ref       = get(a:000,0,{})

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])

  if len(htmllines)
    let htmltext=join(htmllines,"\n")
  endif

  let lines = []

perl << eof

  use Vim::Perl qw(:funcs :vars);
  use HTML::Work;

  my $html  = VimVar('htmltext');

  our $HTW ||= HTML::Work->new(
    html    => $html,
    sub_log => sub { VimMsg($_) for(@_); },
  );
  $HTW->replace_a;

  my @lines   = $HTW->htmllines;

  VimListExtend(lines,\@lines);

eof
  return lines

endfunction

function! base#html#htw_init (...)
  let ref = get(a:000,0,{})

  let dbfile = ':memory:'
  let dbfile = base#htw_dbfile() 
  let dbfile = get(ref,'dbfile',dbfile)

  let load_as = 'html'
  let load_as = strlen(&ft) ? &ft : load_as
  let load_as = get(ref,'load_as',load_as)

  "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  let msg = ['start']
  let prf = {'plugin' : 'base', 'func' : 'base#html#htw_init'}
  call base#log(msg,prf)
  let l:start=localtime()
  "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

perl << eof
  use HTML::Work;

  my $dbfile  = VimVar('dbfile');

  my $load_as = VimVar('load_as');

  my $prf = { dbfile => $dbfile };
  our $HTW ||= HTML::Work->new(
      def_PRINT => sub { VimMsg([@_],$prf) },
      def_WARN  => sub { VimWarn([@_],$prf) },
      dbfile    => $dbfile,
      load_as   => $load_as,
  );
eof
endfunction

function! base#html#fetch_file (...)
  call base#html#htw_init ()

  let ref = get(a:000,0,{})

  let remote = get(ref,'remote','')
  let local  = get(ref,'local','')

perl << eof
  use Vim::Perl qw(VimVar);

  my $remote = VimVar('remote');
  my $local  = VimVar('local');

  $HTW->fetch_file({ 
    remote => $remote,
    local  => $local,
  });
eof

endfunction

function! base#html#download_site (...)
  call base#html#htw_init()

  let ref      = get(a:000,0,{})

  " required
  let save_dir = get(ref,'save_dir','')
  let root     = get(ref,'root','')
  let bname    = get(ref,'bname','')

  let site     = get(ref,'site','')

  " optional
  let proto    = get(ref,'proto','http')

perl << eof
  my $save_dir = VimVar('save_dir');
  my $root     = VimVar('root');
  my $bname    = VimVar('bname');
  my $proto    = VimVar('proto');

  $HTW->download_site({
      savedir     => $save_dir,
      root        => $root,
      bname       => 'index',
      bnames_find => 1,
      proto       => $proto,
  });
eof

endfunction

function! base#html#save_db(...)
    let save_db = base#qw#catpath('db','saved_urls.sqlite')
    return save_db
endfunction

function! base#html#xpath_attr (...)
  call base#html#htw_init ()

  let ref = get(a:000,0,{})

  let xpath     = get(ref,'xpath','')
  let attr_list = get(ref,'attr',[])

  let attr_values=[]

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])

  let file      = get(ref,'file','')

  if filereadable(file)
    let htmllines = readfile(file)
  endif

  if len(htmllines)
     let htmltext = join(htmllines,"\n")
  endif

  let load_as      = base#html#libxml_load_as()
  let load_as      = get(ref,'load_as',load_as)

perl << eof
    use Vim::Perl qw(:funcs :vars);
    use XML::LibXML;

    my $ref          = VimVar('ref') || {};

    my $html         = VimVar('htmltext');
    my $load_as      = VimVar('load_as');

    my $xpath     = VimVar('xpath') || '';

    my $attr_list = VimVar('attr_list') || [];
    my $attr_values  = [];

    my @nodes = $HTW
      ->init_dom({ 
          html    => $html,
      ,   load_as => $load_as,
      })
      ->nodes({ xpath => $xpath });

    foreach my $attr_name (@$attr_list) {
      foreach my $n (@nodes) {
        my $attr = $n->getAttribute($attr_name);

        my $val = ((defined $attr) ? $attr : '');

        push @$attr_values, $val;
      }
    }
    VimListExtend('attr_values',$attr_values);
eof
    return attr_values

endfunction


function! base#html#list_href ()
  call base#html#htw_init ()
  let href = []
perl << eof
  my @href = $HTW->list_attr({ 
    xpath       => '//a',
    node_filter => sub{ 1 },
    attr        => 'href',
  });
  VimLet('href',[@href]);
eof
  return href

endfunction

function! base#html#htw_load_buf ( ... )
  call base#html#htw_init ()

  "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  let msg = ['start']
  let prf = {'plugin' : 'base', 'func' : 'base#html#htw_load_buf'}
  call base#log(msg,prf)
  let l:start = localtime()
  "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


  let load_as      = base#html#libxml_load_as()
  let load_as      = &ft
perl << eof
  use Vim::Perl qw(:funcs :vars);
  $Vim::Perl::CURBUF = $curbuf;

  my $load_as = VimVar('load_as');
  my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];
  $HTW
    ->init_dom({ 
        htmllines => $lines,
        load_as   => $load_as,
    })
    ;
  our $DOM = $HTW->{dom};
eof
  
endfunction

function! base#html#xp (...)
  let ref = get(a:000,0,{})
  let id  = get(ref,'id','')

  let xpath = ''
perl << eof
  my $id = VimVar('id');
  use Base::HTML qw(xp);

  my $xpath = xp($id);
  VimLet('xpath',$xpath);
eof
  return xpath
endfunction

function! base#html#css_select(...)
  if !has('perl') | return | endif

  call base#html#htw_init()

endfunction

function! base#html#xpath(...)
  if !has('perl') | return | endif

  "initialize perl's global $HTW variable (instance of HTML::Work)
  call base#html#htw_init()

  let ref      = get(a:000,0,{})

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])
  let xpath     = get(ref,'xpath','')

  let file      = get(ref,'file','')

  let add_comments    = get(ref,'add_comments',0)
  let cdata2text      = get(ref,'cdata2text',0)
  let decode_entities = get(ref,'decode_entities',0)

  let load_as      = base#html#libxml_load_as()
  let load_as      = get(ref,'load_as',load_as)

  let mode         = get(ref,'mode','node_toString')

  if filereadable(file)
    let htmllines = readfile(file)
  endif

  if len(htmllines)
     let htmltext = join(htmllines,"\n")
  endif

  let filtered = []

perl << eof
  use utf8;
  use Encode;

  use Vim::Perl qw(:funcs :vars);
  use XML::LibXML;
  use HTML::Entities qw(decode_entities);
  use String::Util qw(trim);

  my $html         = VimVar('htmltext');
  my $xpath        = VimVar('xpath');
  my $ref          = VimVar('ref') || {};

  my $decode_entities = VimVar('decode_entities');

  my $add_comments = VimVar('add_comments');
  my $cdata2text   = VimVar('cdata2text');
  my $load_as      = VimVar('load_as');
  my $mode         = VimVar('mode');

  my @nodes = $HTW
    ->init_dom({ 
        html    => $html,
    ,   load_as => $load_as,
    })
    ->nodes({ xpath => $xpath });

  my @filtered;

  for my $node (@nodes){
    my $ntype = $node->nodeType;
    if ($add_comments) {
      my $cmts = [
        'nodeType=' . $nodetypes{$ntype} || 'undef',
      ];
      foreach my $cmt (@$cmts) {
        my $cnode = XML::LibXML::Comment->new($cmt);
        push @filtered, $cnode->toString;
      }
    }

    if ($cdata2text) {
      $node = $HTW->node_cdata2text({ 
        node   => $node,
        dom    => $dom,
        parser => $parser });
    }
    if ($mode eq 'node_toString') {
      push @filtered, split("\n",$node->toString);

    } elsif ($mode eq 'node_textContent') {
      push @filtered, split("\n",$node->textContent);

    } elsif ($mode eq 'node_children_toString') {
      
      my $s = sub {
                my ($n) = @_;
                my @split = split "\n" => $n->toString;
                push @filtered, @split;
              };
      $node
        ->childNodes()
        ->map($s);
      
    }  elsif ($mode eq 'node_children_to_literal') {
      my $s = sub {
                my ($n) = @_;
                my @split = split "\n" => $n->to_literal;
                push @filtered, @split;
              };
      $node
        ->childNodes()
        ->map($s);
    }
  }
  if ($decode_entities) {
    @filtered = map { decode_entities($_) } @filtered;
  }

  if ($ref->{trim}) {
    map { $_ = trim($_) } @filtered;
  }

  if ($ref->{skip_empty}) {
    @filtered = map { /^\s*$/ ? () : $_ } @filtered;
  }

  VimListExtend('filtered',\@filtered);
eof

  return filtered

endfunction

function! base#html#xpath_to_literal(...)
  if !has('perl') | return | endif

  let ref      = get(a:000,0,{})

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])
  let xpath     = get(ref,'xpath','')

  if len(htmllines)
     let htmltext = join(htmllines,"\n")
  endif
  let text = ''

perl << eof
  use Vim::Perl qw(:funcs :vars);
  use XML::LibXML;
  use XML::LibXML::PrettyPrint;

  my $html  = VimVar('htmltext');
  my $xpath = VimVar('xpath');

  my ($dom, @nodes, @filtered);

  $dom = XML::LibXML->load_html(
      string          => decode('utf-8',$html),
      recover         => 1,
      suppress_errors => 1,
  );

  my $s = $dom->findnodes($xpath)->to_literal;
  VimLet('text',"$s");
eof
  return text

endfunction

function! base#html#xpath_lineno(...)
  if !has('perl') | return | endif

  let ref      = get(a:000,0,{})

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])
  let xpath     = get(ref,'xpath','')

  if len(htmllines)
     let htmltext = join(htmllines,"\n")
  endif

  let filtered=split(htmltext,"\n")
  let filtered=[]
  if !strlen(xpath)
    echohl WarningMsg
    echo 'Empty XPATH'
    echohl None
    return filtered
  endif

perl << eof
  # read https://habrahabr.ru/post/53578/ about encodings
  # http://www.nestor.minsk.by/sr/2008/09/sr80902.html
  use utf8;
  use Encode;

  use Vim::Perl qw(:funcs :vars);
  use XML::LibXML;
  use XML::LibXML::PrettyPrint;

  my $html  = VimVar('htmltext');
  my $xpath = VimVar('xpath');

  my ($dom,@nodes,@filtered);

  $dom = XML::LibXML->load_html(
      string          => decode('utf-8',$html),
      recover         => 1,
      suppress_errors => 1,
  );

  @nodes = $dom->findnodes($xpath);

  for my $node (@nodes){
    VimLet('string',$node->toString);
    VimLet('lnum',$node->line_number);
    VimLet('text',$node->textContent || '');
    my $cmd = 'call add(filtered,' ;
    $cmd .='{ "lnum"   : lnum, '   ;
    $cmd .='  "text"   : text,'    ;
    $cmd .='  "string" : string,'  ;
    $cmd .='})'                    ;
    VimCmd($cmd);
  }

eof

  return filtered

endfunction

function! base#html#xpath_remove_nodes(...)
  if !has('perl') | return | endif

  call base#html#htw_init()

  let ref      = get(a:000,0,{})

  let opts    = base#varget('opts',{})
  let load_as = get(opts,'libxml_load_as','')
  let load_as = get(ref,'load_as',load_as)

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])
  let xpath     = get(ref,'xpath','')

  if len(htmllines)
     let htmltext=join(htmllines,"\n")
  endif

perl << eof
  use utf8;
  use Encode;

  use Vim::Perl qw(:funcs :vars);
  use HTML::Work;

  my $ref     = VimVar('ref') || {};

  my $html    = VimVar('htmltext');
  my $xpath   = VimVar('xpath');
  my $load_as = VimVar('load_as');

  $html = $HTW
    ->init_dom({ 
      html    => $html,
      load_as => $load_as,
    })
    ->nodes_remove({ xpath => $xpath })
    ->htmlstr;

  if ($ref->{fillbuf}) {
    CurBufSet({ text => $html, curbuf => $curbuf });
  }
  VimLet('htmltext',html);
  return $html;
eof

endfunction

function! base#html#xpath_remove_attr(...)
  if !has('perl') | return | endif

  let ref      = get(a:000,0,{})

  let opts    = base#varget('opts',{})
  let load_as = get(opts,'libxml_load_as','')
  let load_as = get(ref,'load_as',load_as)

  let htmltext  = get(ref,'htmltext','')
  let htmllines = get(ref,'htmllines',[])
  let xpath     = get(ref,'xpath','')

  if len(htmllines)
     let htmltext=join(htmllines,"\n")
  endif

perl << eof
  use utf8;
  use Encode;

  use Vim::Perl qw(:funcs :vars);
  use HTML::Work;

  my $ref     = VimVar('ref') || {};

  my $html    = VimVar('htmltext');
  my $xpath   = VimVar('xpath');
  my $load_as = VimVar('load_as');

  our $HTW ||= HTML::Work->new(sub_log => sub { VimWarn(@_); });

  $html = $HTW
    ->init_dom({ 
      html    => $html,
      load_as => $load_as,
    })
    ->nodes_remove_attr({ xpath => $xpath })
    ->htmlstr;

  if ($ref->{fillbuf}) {
    CurBufSet({ text => $html });
  }
  VimLet('htmltext',html);
  return $html;
eof

endfunction


function! base#html#list_to_txt(html)
  if !has('perl')
    return
  endif
  let lines=[]

perl << eof
  use utf8;
  use Encode;

  use Vim::Perl qw(:funcs :vars);
  use XML::LibXML;

  my $html=VimVar('a:html');

  my $doc = XML::LibXML->load_html(
      string          => decode('utf-8',$html),
      recover         => 1,
      suppress_errors => 1,
  );
  my $xpath='//[ul|ol]/li'

  my @nodes=$dom->findnodes($xpath);
eof
 " my @filtered;

  "for(@nodes){
    "push @filtered,split("\n",$_->toString);
  "}

  "VimListExtend('filtered',\@filtered);

endfunction


function! base#html#libxml_load_as()
  let opts    = base#varget('opts',{})
  let load_as = get(opts,'libxml_load_as','')
  return load_as
endfunction

function! base#html#pretty_libxml(...)
  
  if !has('perl') | return [] | endif

  let ref      = get(a:000,0,{})
  let htmltext = get(ref,'htmltext','')

  let load_as      = base#html#libxml_load_as()
  let load_as      = get(ref,'load_as',load_as)

  let html_pp=[]

perl << eof
  use utf8;
  use Encode;

  use Vim::Perl qw(:funcs :vars);
  use HTML::Work;

  our $HTW  ||= HTML::Work->new( sub_log => sub { VimWarn(@_); } );

  my $ref     = VimVar('ref');
  my $load_as = VimVar('load_as');

  my $html = VimVar('htmltext');

  my $html_pp = $HTW
    ->init_dom({ 
      html    => $html,
      load_as => $load_as,
    })
    ->dom_pretty
    ->htmlstr;

  if ($ref->{fillbuf}) {
    my $c=$curbuf->Count(); 
    $curbuf->Delete(1,$c);
    $curbuf->Append(1,split("\n",$html_pp));
  }

  push @pp,(split("\n",$html_pp));
  VimListExtend('html_pp',\@pp);
eof

  return html_pp

endfunction
