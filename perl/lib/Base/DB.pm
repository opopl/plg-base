
package Base::DB;

=head1 NAME

Base::DB

=head1  SYNOPSIS

    use Base::DB qw(:funcs :vars);

=cut

use strict;
use warnings;


use base qw(Exporter);


use DBI;
use Base::Arg qw(
    hash_apply
);

use File::Find::Rule;
use File::Slurp::Unicode;
use File::Spec::Functions qw(catfile);

use String::Util qw(trim);
use SQLite::More;

use utf8;
use open qw(:utf8 :std);

use vars qw(
    $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS

    $DBH
    $DBH_CACHE
    $WARN
);

@ISA     = qw(Exporter);
@EXPORT  = qw( );
$VERSION = '0.01';

use SQL::SplitStatement;
use Data::Dumper;

###export_vars_scalar
my @ex_vars_scalar = qw(
    $DBH
    $DBH_CACHE
);
###export_vars_hash
my @ex_vars_hash = qw(
);
###export_vars_array
my @ex_vars_array = qw();

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw(
    dbi_connect

    dbh_insert_hash
    dbh_insert_update_hash

    dbh_base2info

    dbh_create_fk
    dbh_create_tables

    dbh_select
    dbh_select_join
    dbh_select_first
    dbh_select_as_list
    dbh_select_fetchone

    dbh_do
    dbh_delete

    dbh_list_tables
    dbh_selectall_arrayref
    dbh_sth_exec
    dbh_update_hash

    cond_where
    cond_inner_join

    jcond
    _sql_ct_info
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

=head1 EXPORTED VARS

    $DBH

=head1 EXPORTED FUNCTIONS

=head2 dbi_connect

=head3 Usage

    use Base::DB qw( dbi_connect );

    my $ref = {
        # dbfile
        dbfile => $dbfile,

        # optional, dsn
        dsn => $dsn,

        # optional, user + pwd
        user => $user,
        pwd  => $password,

        # optional, DBI driver name,
        #   default: sqlite
        driver => $driver,

        # attributes passed on to DBI->connect
        attr => $attr || {},

    };

    my $dbh = dbi_connect($ref);

=cut

sub dbi_connect {
    my ($ref) = @_;

    my $dbfile = $ref->{dbfile};
    my $warn   = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $fk = $ref->{fk} || 1;

    my $drivers = {
        sqlite => 'SQLite'
    };
    my $drv     = $ref->{driver} || 'sqlite';
    my $drv_dbi = $drivers->{$drv} || $drv;

    my $dsn      = $ref->{dsn} || "dbi:$drv_dbi:dbname=$dbfile";
    my $user     = $ref->{user} || "";
    my $password = $ref->{pwd} || "";

    my $attr     = {
        PrintError       => 0,
        RaiseError       => 1,
        AutoCommit       => 1,
        FetchHashKeyName => 'NAME_lc',
        sqlite_unicode   => 1,
    };
    hash_apply($attr, $ref->{attr});

    my $dbh = eval { DBI->connect($dsn, $user, $password, $attr ) };
    if ($@) { $warn->( $@, DBI->errstr ); return; }

    sqlite_more($dbh) if $dbh;

    if ($fk) {
      dbh_do({
         dbh => $dbh,
         q => 'PRAGMA foreign_keys=ON'
      });
    }
    return $dbh;
}

sub dbh_cache_get {
    my ($q) = @_;
    my $res = $DBH_CACHE->{$q};
    return $res;
}

sub dbh_cache_add {
    my ($q, $res) = @_;
    $DBH_CACHE->{$q} = $res;
    return 1;
}


=head2 dbh_select

=head3 Usage

    my $ref = {
        # (STRING) table
        t => TABLE,

        # (ARRAYREF) fields
        f => [ FIELD1, FIELD2, ... ],

        # (STRING) query, will override what
        #   has been provided via 'f' and 't' fields
        #   specified above
        #
        q => q{ SELECT a FROM t },

        # (ARRAYREF) bind params
        p => [ $b ],

        # WHERE ... AND ... statement
        w => { ... },

        # LIMIT (\d+)
        limit => 10,

        # (STRING) additional conditions
        cond => q{ WHERE b = ? },
    };
    my ($rows,$cols) = dbh_select($ref);

=cut

sub dbh_select {
    my ($ref) = @_;

    $ref ||= {};

    my $dbh = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $dbfile = $ref->{dbfile};

    my $use_cache = $ref->{use_cache};

    if($dbfile){
        $dbh = dbi_connect($ref);
        $ref->{close} ||= 1;
    }

    # fields
    my @f = @{$ref->{f} || []};

    # params
    my @p = @{$ref->{p} || []};

    # table
    my $t = $ref->{t} || '';
    $t = trim($t);

    my $t_alias = $ref->{t_alias} || $t;

    # query if input
    my $q = $ref->{q};

    # where ... AND statement
    my $w = $ref->{w} || {};

    my $inner_join = $ref->{ij} || {};

    my $fetch = $ref->{fetch} || 'fetchrow_hashref';

    # additional conditions
    my $cond = $ref->{cond} || '';

    my $SELECT = $ref->{s} || 'SELECT';

    #my $e = q{`};
    my $e = q{};
    my $f = (@f) ? join ',' => map {
        $_ = trim($_);
        my ($start, $as) = ( m/(.*)\^(\w+)$/g );
        my $expr = $as ? join(' AS ' => $start, $as) : $_;

        my $res = $e . trim($expr) . $e;
        $res;
    } @f : '*';

    my $t_str = ( $t eq $t_alias ) ? $t : qq{ $t $t_alias };
    $q ||= qq|
        $SELECT $f FROM $t_str
    |;

    $q .= cond_inner_join($t, $t_alias, $inner_join);

    my ($q_wh, $p_wh) = cond_where($w);
    $q .= $q_wh;
    push @p, @$p_wh;

    $q .= ' ' . $cond;

    my $limit = $ref->{limit};
    if ($limit){ $q .= ' LIMIT ' . $limit }

    if ($use_cache) {
        my $res = dbh_cache_get({ q => $q });
        if ($res) {
            my ($rows, $cols) = @{$res}{qw( rows cols )};
            return ($rows, $cols);
        }
    }
    #$DB::single = 1;

    my $sth;
    eval { $sth = $dbh->prepare($q); };
    if($@){ $warn->($@,$dbh->errstr,$q);  }

    if (not defined $sth) {
        my @w;
        push @w,
            'sth undefined!','query:',$q,'params:',@p,'dbh->errstr=',$dbh->errstr;
        $warn->(@w);
        return [];
    }

    eval { $sth->execute(@p) or do { $warn->($dbh->errstr,$q,@p); }; };
    if($@){ $warn->($@,$dbh->errstr,$q,@p); }

    my $rows = [];

    while ( my $row = $sth->$fetch() ) {
        push @$rows, { %$row } if ref $row eq 'HASH' ;
        push @$rows, [ @$row ]  if ref $row eq 'ARRAY' ;
    }
    my $cols = $sth->{NAME_lc} || [];

    if ($ref->{close}) {
        if($dbfile && $dbh){
            eval { $dbh->disconnect; };
            if ($@) { $warn->($@); }
        }
    }

    if ($use_cache) {
        my $res = {
            rows => $rows,
            cols => $cols,
        };
        dbh_cache_add({
            q   => $q,
            res => $res
        });
    }

    return ($rows, $cols, $q, [@p]);
}

sub dbh_select_join {
    my ($select) = @_;
    $select ||= {};

    my $list = [];

    my $dbh = $select->{dbh} || $DBH;

    # mode for output: list, rows
    my $mode = $select->{mode} || 'list';

    # e.g. tags author_id
    my $keys = $select->{keys} || [];

    # base table
    my $tbase = $select->{tbase} || '';

    # base table alias
    my $tbase_alias = $select->{tbase_alias} || 'p';

    my $on_key = $select->{on_key} || '';

    # base table fields
    my $f = $select->{f} || [];

    # e.g. tags => tag
    my $key2col = $select->{key2col} || {};

    my (%wh, %conds, %tbls);
    my (@cond, @params);

    my $ops = $select->{'@op'} || 'and';
    my $limit = $select->{limit} || '';
    my $where = $select->{where} || {};

    my @ij;
    foreach my $key (@$keys) {
        # alias index for joined tables, e.g. t0, t1, ...
        my $ia = 0;

        my @cond_k;

        my $wk = $wh{$key} = $select->{$key};
        next unless $wk;

        my $colk = $key2col->{$key} || $key;
        my $tk = sprintf('_info_%s_%s', $tbase, $key);

        if (ref $wk eq 'HASH') {
          foreach my $op (qw( or and )) {
            my $vals = $wk->{$op};
            next unless $vals;
            next unless ref $vals eq 'ARRAY';

            my @cond_op;

            foreach my $v (@$vals) {
              $ia++;
              my $tka = $key . $ia;
              push @ij, {
                 'tbl'       => $tk,
                 'tbl_alias' => $tka,
                 'on'        => $on_key,
              };
              push @cond_op, sprintf('%s.%s = ?', $tka, $colk);
              push @params, $v;
            }
            push @cond_k, jcond($op => \@cond_op);
          }
        }

        my $opk = $wk->{'@op'} || 'and';
        push @cond, jcond($opk => \@cond_k, braces => 1);
    }

    my ($q_where, $p_where) = cond_where($where);
    if ($q_where) {
        $q_where =~ s/^\s*WHERE//g;
        push @cond, $q_where;
        push @params, @$p_where;
    }

    my $cond;
    if (@cond) {
      $cond = 'WHERE ';
      $cond .= jcond($ops => \@cond, braces => 1);
    }

    my $ref = {
        dbh     => $dbh,
        t       => $tbase,
        t_alias => $tbase_alias,
        f       => [ map { "$tbase_alias.$_" } @$f ],
        ij      => \@ij,
        p       => \@params,
        cond    => $cond,
        limit   => $limit,
    };

    if ($mode eq 'list') {
       push @$list, dbh_select_as_list($ref);
    }elsif ($mode eq 'rows') {
       my ($rows) = dbh_select($ref);
       push @$list, @$rows;
    }

    $DB::single = 1 if $select->{dbg};

    wantarray ? @$list : $list ;
}


sub dbh_select_as_list {
    my ($ref)  = @_;

    my ($rows, $cols) = dbh_select($ref);
    my @list = map { my $row = $_; map { $row->{$_} } @$cols } @$rows;

    return wantarray ? @list : \@list;

}


sub dbh_list_tables {
    my ($ref)  = @_;

    $ref ||= {};

    my $q = q{
        SELECT
            name
        FROM
            sqlite_master
        WHERE
            type IN ('table','view') AND name NOT LIKE 'sqlite_%'
        UNION ALL
        SELECT
            name
        FROM
            sqlite_temp_master
        WHERE
            type IN ('table','view')
        ORDER BY 1
    };

    my @t = dbh_select_as_list({ %$ref, q => $q });

    wantarray ? @t : \@t;
}

sub dbh_select_fetchone {
    my ($ref)  = @_;

    my $list = dbh_select_as_list($ref);

    my $res = $list->[0];
    return $res;
}


sub dbh_select_first {
    my ($ref)  = @_;

    my ($rows, $cols, $q, $p) = dbh_select($ref);
    my $row = $rows->[0];

    return ($row, $cols, $q, $p);

}


sub dbh_selectall_arrayref {
    my ($ref)  = @_;

    my $dbh = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); }

    # query
    my $q   = $ref->{q} || '';

    # params
    my $p   = $ref->{p} || [];

    my $res = [];

    my $spl = SQL::SplitStatement->new;
    my @q   = $spl->split($q);

    for my $q (@q){
        my $rows;
        eval { $rows = $dbh->selectall_arrayref($q,{},@$p) or
            do { $warn->($q,$dbh->errstr);  };
        };
        if ($@) { $warn->($q,$@,$dbh->errstr); }

        push @$res,{
            q    => $q,
            rows => $rows,
            err  => $dbh->err ? [$dbh->errstr] : [],
        };
    }

    if ($ref->{close}) {
        if($dbfile && $dbh){
            eval { $dbh->disconnect; };
            if ($@) { $warn->($@); }
        }
    }

    return $res;

}

=head2 dbh_insert_hash

=head3 Usage

    dbh_insert_hash({
        # database handle
        dbh => $dbh,

        # input hash of values
        h => $hash,

        # table name
        t => $table,

        # insert command (optional)
        #   default is 'INSERT'
        i => 'INSERT OR IGNORE',

        # subroutine for warnings (optional)
        #   default is:
        #       sub { warn $_ for(@_); }
        warn => sub { ... },
    });

=head3 Purpose

    insert hash of values into table.

=cut

sub dbh_insert_hash {
    my ($ref)=@_;

    my $dbh = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); }

    my $h = $ref->{h} || {};
    my $t = $ref->{t} || '';
    $t = trim($t);

    my $INSERT = $ref->{i} || 'INSERT';

    unless (keys %$h) {
        return;
    }

    my $ph = join ',' => map { '?' } keys %$h;
    my @f = keys %$h;
    my @v = map { $h->{$_} } @f ;
    my $e = q{`};
    my $f = join ',' => map { $e . $_ . $e } @f;

    my $q = qq| $INSERT INTO `$t` ($f) VALUES ($ph) |;

    my $ok = eval { $dbh->do($q, undef, @v); };
    if ($@) {
        $warn->($@, $q, $dbh->errstr);
        return;
    }

    if($dbfile && $dbh){
        eval { $dbh->disconnect; };
        if ($@) { $warn->($@); }
    }

    return $ok;
}

sub _sql_ct_info {
   my ($ref) = @_;
   $ref ||= {};

   # 'base' table
   my $tbase = $ref->{tbase} || '';

   # join column
   my $jcol = $ref->{jcol} || '';

   # 'base' column
   my $bcol = $ref->{bcol} || '';

   # 'info' column
   my $icol = $ref->{icol} || $bcol;

   return unless $tbase && $bcol && $icol && $jcol;

   my $itb = q{_info_}. $tbase . q{_} . $bcol;

   my $q = qq{ CREATE TABLE IF NOT EXISTS $itb (
        $jcol TEXT NOT NULL,
        $icol TEXT,
        FOREIGN KEY($jcol) REFERENCES $tbase($jcol)
            ON DELETE CASCADE
            ON UPDATE CASCADE
      );
   };

   return $q;
}

# see also base2info in DBW.py

sub dbh_base2info {
  my ($ref) = @_;

  my $dbh = $ref->{dbh} || $DBH;
  my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

  # database file
  my $dbfile = $ref->{dbfile};
  if($dbfile){ $dbh = dbi_connect($ref); }

  # initial ('base') table
  my $tbase = $ref->{'tbase'} // '';

  # where condition for 'base' table
  my $bwhere = $ref->{'bwhere'} // {};

  # 'join' column, i.e. foreign key field
  #   which 'joins' 'base' and 'info' tables
  my $jcol = $ref->{'jcol'} // '';

  # 'base' => 'info' columns mapping
  my $b2i = $ref->{'b2i'} // {};

  # columns in 'base' table which have to
  #   be expanded into 'info' table
  my $bcols = $ref->{'bcols'} // [];

  # additional options
  my $opts = $ref->{'opts'} // {};
  my $length = $opts->{length} // 0;

  # for each of the 'base' columns labeled as 'bcol',
  #    create corresponding 'info' table
  foreach my $bcol (@$bcols) {
     my $icol = $b2i->{$bcol} // $bcol;
     my $sql = _sql_ct_info({
        tbase => $tbase,
        bcol  => $bcol,
        jcol  => $jcol,
        icol  => $icol,
     });
     dbh_do({
        dbh => $dbh,
        q   => $sql,
     });
  }

  my $scols = [ $jcol ];
  push @$scols, @$bcols;

  my $ok = 1;

  my $cond = $length ? join(" OR " => map { "LENGTH($_) > 0" } @$bcols ) : '';
  my ($cond_bw, $p_bw) = cond_where($bwhere);
  if ($cond_bw) {
    $cond_bw =~ s/^\s*WHERE\s+//g;
    if ($cond) {
      $cond = qq{ WHERE ($cond) AND ($cond_bw) };
    }else{
      $cond = qq{ WHERE $cond_bw };
    }
  }else{
    $cond = qq{ WHERE $cond } if $cond;
  }

  my ($rows_base) = dbh_select({
     dbh  => $dbh,
     t    => $tbase,
     f    => $scols,
     cond => $cond,
     p    => $p_bw,
  });

  foreach my $rw (@$rows_base) {
     my $jval = $rw->{$jcol} // '';
     foreach my $bcol (@$bcols) {
       # 'info' column name (icol) in the relevent 'info' table (itb)
       my $icol = $b2i->{$bcol} // $bcol;

       # 'info' table name
       my $itb = sprintf(q{_info_%s_%s}, $tbase, $bcol);

       # comma-separated value
       my $bval = $rw->{$bcol} // '';

       #my $ivals = string.split_n_trim(bval,sep=',')
       my @ivals = map { length $_ ? trim($_) : () } split ',' => $bval;

       $ok &&= dbh_delete({
          dbh => $dbh,
          t   => $itb,
          w   => { $jcol => $jval }
       });

       foreach my $ival (@ivals) {
           my $ins = {
              $jcol => $jval,
              $icol => $ival
           };
           my ($rows) = dbh_select({
              dbh => $dbh,
              t   => $itb,
              w   => $ins
           });
           unless (@$rows) {
              $ok &&= dbh_insert_hash({
                 dbh => $dbh,
                 t   => $itb,
                 h   => $ins
              })
           }
       }
     }
  }

  return $ok;

}

sub dbh_insert_update_hash {
    my ($ref) = @_;

    my $dbh  = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); }

    # data to insert
    my $h = $ref->{h} || {};

    # uniq row
    my $uniq = $ref->{uniq};

    # table name
    my $t = $ref->{t} || '';
    $t = trim($t);

    # insert command
    my $INSERT  = $ref->{i} || 'INSERT';

    my $on_list = $ref->{on_list} || [];
    @$on_list = keys %$h if $uniq;

    my $on_w = {};
    foreach my $on (@$on_list) {
        my $on_val = $h->{$on} // '';
        $on_w->{$on} = $on_val;
    }

    my $w_cond = '';
    my (@w_cond_a, @w_values);
    while( my($on, $on_val) = each %$on_w){
       push @w_cond_a, qq{ $on = ? };
       push @w_values, $on_val;
    }
    $w_cond = join(" and " => @w_cond_a);

    my $ok = 1;

    my $cnt;
    {
      my $q = qq{ SELECT COUNT(*) FROM $t WHERE $w_cond };
      my $p = [@w_values];
      $cnt = dbh_select_fetchone({ dbh => $dbh, q => $q, p => $p });
    }

    unless ($cnt) {
       $ok &&= dbh_insert_hash({
          dbh => $dbh,
          t   => $t,
          h   => $h,
          i   => $INSERT,
       });
    }else{
       foreach my $on (@$on_list) {
          delete $h->{$on};
       }
       if (keys %$h) {
           $ok &&= dbh_update_hash({
              dbh => $dbh,
              t   => $t,
              h   => $h,
              w   => $on_w,
           });
       }
    }

    return $ok;
}

=head2 dbh_update_hash

=head3 Usage

    use Base::DB qw(dbh_update_hash);

    my $ref = {
        # OPTIONAL, database handle,
        #   if not provided, package's $DBH variable
        #   will be used
        dbh => $dbh,

        # OPTIONAL, database file
        dbfile => $dbfile,

        # OPTIONAL, subroutine used for warnings
        #   if not provided, will use package's $WARN variable
        warn => sub { ... },

        # OPTIONAL, modified UPDATE statement,
        #   default: 'UPDATE'
        u => q{UPDATE},

        # REQUIRED, table name
        t => $table,

        # REQUIRED, hash with what needs to be updated
        h => { ... },

        # REQUIRED, WHERE clause contents
        w => { ... },
    };
    dbh_update_hash($ref);

=cut

sub dbh_update_hash {
    my ($ref) = @_;

    my $dbh = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); }

    my $h = $ref->{h} || {};
    my $t = $ref->{t} || '';
    $t = trim($t);

    my $UPDATE = $ref->{u} || 'UPDATE';
    my $w      = $ref->{w} || {};

    unless (keys %$h) { return; }
    unless ($t) { return; }

    my @fields_update = keys %$h;
    my @values_update = map { $h->{$_} } @fields_update ;

    my $e = q{`};

    my @set = map { $e . trim($_) . $e . "= ? " } @fields_update;
    my $set = join "," => @set;
    my $q = qq| $UPDATE `$t` SET $set |;

    my ($q_wh, $p_wh) = cond_where($w);

    $q .= $q_wh;

    my @p = ( @values_update, @$p_wh );
    my $ok = eval { $dbh->do($q,undef,@p); };
    if ($@) {
        $warn->($@,$q,$dbh->errstr);
        return;
    }

    if($dbfile && $dbh){
        eval { $dbh->disconnect; };
        if ($@) { $warn->($@); }
    }

    return $ok;
}

sub jcond {
   my ($op, $cond, %opts) = @_;
   $cond //= [];

   my $tf = $opts{braces} ? sub { '( ' . shift . ' )' } : sub { shift };

   $op = sprintf(' %s ',uc $op);
   my $jnd = join $op => map { $_ ? $tf->($_) : () } @$cond;

   return $jnd;
}

sub cond_inner_join {
    my ($main, $main_alias, $ij) = @_;
    $ij ||= {};

    $main_alias ||= $main;

    my $cij='';
    if (ref $ij eq 'HASH') {
        my $on  = $ij->{on};

        my $tbl       = $ij->{tbl};
        my $tbl_alias = $ij->{tbl_alias} || $tbl;

        if ($on && $tbl) {
            my $tbl_str = ( $tbl_alias eq $tbl ) ? $tbl : qq{ $tbl $tbl_alias };
            $cij .= qq{ INNER JOIN $tbl_str ON $main_alias.$on = $tbl_alias.$on };
            $cij .= "\n";
        }

    } elsif (ref $ij eq 'ARRAY') {
        foreach my $x (@$ij) {
            $cij .= cond_inner_join($main, $main_alias, $x);
        }
    }

    return $cij;
}

sub cond_where {
    my ($w, $sep) = @_;
    $sep ||= 'AND';

    my $e = q{`};

    if (ref $w eq 'ARRAY') {
        my (@cond, @params);
        foreach my $ww (@$w) {
            my ($c, $p) = cond_where($ww);
            next unless $c;
            $c =~ s/^\s+WHERE\s+//g;
            $c = trim($c);
            push @cond, $c;
            push @params, @$p;
        }

        my $q = q{ WHERE } . join(' OR ', map { '( '. $_ .' )'  } @cond);
        return ($q, [@params]);
    }

    my @fields_where = keys %$w;
    my @values_where;

    my @cond_a;
    foreach my $k (@fields_where) {
        my $v = $w->{$k};

        unless (ref $v) {
            push @values_where, $v;
            push @cond_a, trim($k) . ' = ? ';

        }elsif(ref $v eq 'HASH'){
            if ($k eq '@regexp') {
               while(my ($key, $pat) = each %$v){
                  next unless $pat;
                  push @cond_a, sprintf(' RGX("%s",%s) IS NOT NULL ', $pat, $key);
               }
            }
        }
        elsif(ref $v eq 'ARRAY'){
            push @cond_a, join ' OR ' => map { $k . ' = ? ' } @$v;
            push @values_where, @$v;
        }

    }

    my $q = '';
    if (@cond_a) {
        $q .= q{ WHERE } . join(sprintf(' %s ',$sep), @cond_a);
    }

    my @p = @values_where;

    return ( $q, [@p] );
}

=head2 dbh_do

=head3 Purpose

    Wrapper around DBI's do() method.

=head3 Usage

    use Base::DB qw(dbh_do);

    my $ref = {
        # OPTIONAL, will use package's $DBH variable
        #   if not set
        dbh => $dbh,

        # OPTIONAL
        warn => $warn,

        # OPTIONAL
        dbfile => $dbfile,

        # REQUIRED
        q => q{ SELECT remote FROM saved WHERE ... },

        # OPTIONAL, needed when query needs parameter binding
        #   array of values of bound parameters
        p => [ ... ],
    };

    my $ok = dbh_do($ref);

=head3 Returns

Integer value.

=over 4

=item * 1 - success

=item * 0 - failure

=back

=cut

sub dbh_do  {
    my ($ref)=@_;

    my $dbh  = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $close = $ref->{close};

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); $close = 1; }

    my $q = $ref->{q} || '';
    my $p = $ref->{p} || [];

    my $spl = SQL::SplitStatement->new;
    my @q = $spl->split($q);

    my $FINE = 1;

    foreach my $query (@q) {
        my $ok;
        eval { $ok = $dbh->do($query,undef,@$p); };
        $FINE=0 unless $ok;
        if ($@) {
            my @w;
            push @w,
                map { ( $_->[0] => $_->[1] ) }   (
                    [ 'Query:', $query ],
                    [ 'Query parameters:', Dumper($p) ],
                    [ 'DBI $dbh->errstr:', $dbh->errstr ],
                    [ 'Captured error output:', $@ ]
                )
                ;
            $warn->(@w);
        }

    }

    if ($close) {
        if($dbfile && $dbh){
            eval { $dbh->disconnect; };
            if ($@) { $warn->($@); }
        }
    }

    return $FINE;
}

sub dbh_create_tables {
    my ($ref)  = @_;

    my $dbh = $ref->{dbh} || $DBH;

    my $rule = File::Find::Rule->new;

    my $sql_dir = $ref->{sql_dir};
    return unless $sql_dir && -d $sql_dir;

    my $prefix = $ref->{prefix} || 'create_table_';
    my $table_order = $ref->{table_order} || [];
    return unless @$table_order;

    my $ok = 1;
    foreach my $table (@$table_order) {
        my $sql_file = catfile($sql_dir, sprintf('%s%s.sql', $prefix, $table));
        next unless -f $sql_file;

        my $sql_code = read_file $sql_file;
        $ok &&= dbh_do({
           dbh => $dbh,
           q => $sql_code,
        });
    }

    return $ok;
}

sub dbh_create_fk {
    my ($ref)  = @_;
    $ref ||= {};

    my $dbh = $ref->{dbh} || $DBH;

}

sub dbh_delete {
    my ($ref)  = @_;

    my $dbh = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); }

    my $t = $ref->{t} // '';
    my $q = $ref->{q} // '';
    my @p = @{$ref->{p} // []};

    #my @f = @{$ref->{f} // []};
    #my $f = (@f) ? join ',' => map { length ? trim($_) : () } @f : '*';

    my $cond = $ref->{cond} // '';

    $q ||= qq{ DELETE FROM $t };

    # where ... AND statement
    my $w = $ref->{w} // {};
    my ($q_wh, $p_wh) = cond_where($w);
    $q .= $q_wh;
    push @p, @$p_wh;

    $q .= ' ' . $cond;

    my $ok = dbh_do({
       dbh => $dbh,
       q   => $q,
       p   => \@p,
    });

    return $ok;
}

sub dbh_sth_exec {
    my ($ref)  = @_;

    my $dbh = $ref->{dbh} || $DBH;
    my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); }

    my $q   = $ref->{q};
    my @e   = @{ $ref->{p} || [] };

    my $sth;
    my $spl = SQL::SplitStatement->new;

    my @q = $spl->split($q);

    for(@q){
        eval { $sth = $dbh->prepare($_)
                or $warn->($_,$dbh->errstr)
        };
        if ($@) { $warn->($_,$@,$dbh->errstr); }
        eval { $sth->execute(@e); };
        if ($@) { $warn->($_,$@,$dbh->errstr); }
    }


    if($dbfile && $dbh){
        eval { $dbh->disconnect; };
        if ($@) { $warn->($@); }
    }

    $sth;
}

1;


