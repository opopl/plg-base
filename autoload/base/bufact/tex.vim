
function! base#bufact#tex#table_load ()
  call base#buf#start()
  let proj = projs#proj#name()
  let sec = b:sec
perl << eof
  use Vim::Perl qw(:funcs :vars);
  use Data::Dumper;
  use String::Escape qw(escape);
  use Encode qw(decode encode);
  use DBI;

  my $lines = [ $curbuf->Get( 1 .. $curbuf->Count ) ];

  my $is_table=0;
  my $table;
  my %tables;

  my $t='';
  for(@$lines){
      /^%%table\s+(\w+)/ && do { 
        $t=''; 
        $is_table=1; 
        $table=$1;
        next; 
      };

      /^%%endtable\s+(\w+)/ && do { 
        $is_table=0; 
        $t=''; 
        next; 
      };

      if ($is_table) {
        my $tt = $tables{$table} || {};
        $t = $tt->{text} || '';
        $t .= $_ . "\n";
        $tt->{text}=$t;
        $tables{$table}=$tt;
      }
  }

  my $strip_latex = sub { local $_=shift;
    chomp;
    s/^\s*//g; s/\s*$//g;
    s/^\s*\n//g;
    s/\n//g;
    s/\\\\hline//g;
    s/\\\\textbf{(.*)}/$1/g;
    
    $_;
  };

  my $tex2row=sub { 
    my $t=shift; map { $strip_latex->($_) } split('&',$t); 
  };

  foreach my $table (keys %tables) {
    my $t = $tables{$table}->{text};
    #my @rows = map { escape('printable',decode('utf-8',$_)) } split( "\\\\", $t );
    my @rows_t = map { s/\\/\\\\/g; $_ } split( '\\\\\\\\', $t );
    my $header_t = shift @rows_t;
    my @data;

    my @header = $tex2row->($header_t);

    my $j=0;
    foreach my $row_t (@rows_t) {
      my @row = $tex2row->($row_t);
      VimMsg(Dumper([@row]));
      $j++;
    }

  }
eof

endf

function! base#bufact#tex#set_tag_file ()
  call base#buf#start()
  let proj = projs#proj#name()
  let sec = b:sec
perl << eof
  use Vim::Perl qw(:funcs :vars);
  use Data::Dumper;
  my $lines = [ $curbuf->Get( 1 .. $curbuf->Count ) ];

  my $secname = VimVar('sec');

  my $has=0;
  for(@$lines){
      /^%%file\s+/ && do { $has=1; };
  }
  if (!$has) {
    unshift @$lines,('','%%file ' . $secname,'');
    CurBufSet({ curbuf => $curbuf, text => join("\n",@$lines) });
  }
eof
endf


"""bufact_tex_texify
function! base#bufact#tex#texify ()
  let pl   = base#qw#catpath('plg projs scripts bufact tex texify.pl')
  let pl_e = shellescape(pl)
  let f_e  = shellescape(b:file)

  let cmd = join([ 'perl', pl_e, '--file', f_e ], ' ')

  let env = { 
		\	'file' : b:file 
		\	}
  function env.get(temp_file) dict
    let temp_file = a:temp_file
    let code      = self.return_code
		let file      = self.file

		let lines     = readfile(file)
python3 << eof
import vim

lines = vim.eval('lines')
b     = vim.current.buffer

b[:]  = lines
eof
  
    if filereadable(a:temp_file)
      let out = readfile(a:temp_file)
      call base#buf#open_split({ 'lines' : out })
    endif
  endfunction
  
  call asc#run({ 
    \ 'cmd' : cmd, 
    \ 'Fn'  : asc#tab_restore(env) 
    \ })

endf

"""bufact_tex_list_packs
function! base#bufact#tex#list_packs ()
  let pl   = base#qw#catpath('plg projs scripts bufact tex list_packs.pl')
  let pl_e = shellescape(pl)
  let f_e  = shellescape(b:file)

  let cmd = join([ 'perl', pl_e, f_e ], ' ')
  
  let env = {}
  function env.get(temp_file) dict
    let temp_file = a:temp_file
    let code      = self.return_code
  
    if filereadable(a:temp_file)
      let out = readfile(a:temp_file)
      call base#buf#open_split({ 'lines' : out })
    endif
  endfunction
  
  call asc#run({ 
    \ 'cmd' : cmd, 
    \ 'Fn'  : asc#tab_restore(env) 
    \ })

endf

function! base#bufact#tex#perl_latex_tom ()
  call base#buf#start()
perl << eof
  use Vim::Perl qw(:funcs :vars);
  use Data::Dumper;
  use LaTeX::TOM;

  my $lines = [ $curbuf->Get( 1 .. $curbuf->Count ) ];
  my $text  = join("\n",@$lines);

  my ($parser,$tom);
  
  eval { 
    $parser = LaTeX::TOM->new;
    $tom    = $parser->parse($text);
  };
  if ($@) { VimWarn($@); return; }

  my $sections = $tom->getNodesByCondition(sub {
      my $node = shift;
      return (
           $node->getNodeType eq 'COMMAND'
             && $node->getCommandName =~ /section$/
      );
  });
    VimMsg(Dumper(ref $sections));
    #foreach my $x (@$sections) {
    #VimMsg(Dumper($x));
    #}
eof

endf

function! base#bufact#tex#nicer ()
  call tex#act#buf_nice()
  call tex#act#better_tex()
endf
