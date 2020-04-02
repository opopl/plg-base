

function! base#sql#split (sql_query)
  let sql_query=a:sql_query
perl << eof
  use Vim::Perl qw(:funcs :vars);
  use SQL::SplitStatement;

  my $sql_query = VimVar('sql_query');

  my $ss      = SQL::SplitStatement->new;
  my @queries = $ss->split($sql_query);

  VimLet('queries',[@queries]);
eof
  return queries
endf

"used in:
" perlmy#dsql#exec DSQL
function! base#sql#q (sql_query,...)
  let sql_query=a:sql_query

  let ref = get(a:000,0,{})

  let fmt    = get(ref,'pack_fmt','a10')
  let dbtype = get(ref,'dbtype','sqlite')
  let opp    = get(ref,'opt_print','perldumper')
  let fetch  = get(ref,'fetch','fetchrow_arrayref')

  let lines  = []
perl << eof
  use Vim::Perl qw(:funcs :vars);
  use Vim::Dbi;
  use Base::DB;
  use SQL::SplitStatement;

  use utf8;
  use open qw(:std :utf8);

  use Encode;
  use Encode::Locale;

  if (-t) 
  {
    binmode(STDIN,  ":encoding(console_in)");
    binmode(STDOUT, ":encoding(console_out)");
    binmode(STDERR, ":encoding(console_out)");
  }

  my $dbh;

  my $dbtype = VimVar('dbtype');
  for($dbtype){
      /^sqlite$/&& do {
        $dbh=$plgbase->dbh;
        next;
      };
      /^mysql$/&& do {
        $vimdbi->connect;
        $dbh=$vimdbi->dbh;
        next;
      };
      last;
  }

  defined $dbh or do { VimWarn('base#sql#q: $dbh undefined!!'); return; };

  my $sql_query = VimVar('sql_query');
  my $fmt       = VimVar('fmt');
  my $opp       = VimVar('opp');
  my $fetch     = VimVar('fetch');
  my $method    = $fetch;

  VimMsg($sql_query);

  my $ss    = SQL::SplitStatement->new;
  my @stats = $ss->split($sql_query);

  my $debug=sub { 
    return;
    VimMsg([@_]); 
  };

  my $lines=[];
  for(@stats){
    my $query=$_;

    $debug->($_);

    my $sth;
    eval {$sth = $dbh->prepare($query); };
    my $errstr = sub { $dbh->errstr; };
    if ($@) {
      my $s = 'eval {$sth = $dbh->prepare($query);};';
      my @m;
      push @m,  
        'base#sql#q: errors for: ',$s,
        'error thrown:',$@,
        '$dbh->errstr=',$errstr->(),
        'query=',$query;
      VimWarn(@m);
      return;
    }
    defined $sth or do { 
      my @m;
      push @m,
        'base#sql#q: $sth undefined!!',
        '$dbh->errstr=',$errstr->(),
        'query=',$query;
      VimWarn(@m); 
      return; 
    };
  
    my @e=();
    $debug->('executing prepared $sth');
    #$sth->execute(@e);

    eval { $sth->execute(@e); };
    $debug->('executed.',$errstr->());

    if ($@) {
        my $s = q|eval {$sth = $dbh->prepare(@e);};|;
        my @m;
        push @m,  
          'base#sql#q: errors for: ',$s,
          '$dbh->errstr=',$errstr->(),
          'query=',$query,
          ;
          if (@e) {
            push @m,'@e=',Dumper([@e]);
          }
      VimWarn(@m); 
      return; 
    }
#   if ($dbh->err) {
#       VimWarn($dbh->errstr);
#     }else{
#       VimMsg(['executed.',$errstr->()]);
#   }

    my $fetchrow = sub { 
      my $nrow = undef;
      my $row  = undef;
      eval { $row = $sth->$method; }; 
      unless($row){ return; }

      if (ref $row eq 'ARRAY') {
        if ($@) {
          my @m;
            push @m,
            'base#sql#q: errors while $sth->fetchrow...',
            '$dbh->errstr=',$errstr->(),
            $@;
          VimWarn(@m);
          return undef;
        }
        for($method){
          @$nrow=@$row;

          /^fetchrow_arrayref$/ && do {
            @$nrow = map { encode('utf8',$_) } @$row;
            next;
          };

          last;
        }
      }elsif(ref $row eq 'HASH'){
        $nrow = { %$row };
      }
          
      return $nrow;
    };
  
    $debug->('Fetching rows');
    while (my $row=$fetchrow->()) {
      my $line;

      $debug->(Dumper($row));
  
      for($opp){
        /perlpack/ && do {
          $line = pack($fmt,( map { (defined $_) ? $_ : '' } @$row ));
          next;
        };
        /perldumper/ && do {
          $line = Dumper($row);
          next;
        };
        last;
      }
  
      push @$lines, ( split("\n",$line ) );
    }
  }

  VimListExtend('lines',$lines);

# $Vim::Perl::SILENT=0;
  
eof
  return lines
  
endfunction
