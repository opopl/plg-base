
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
    dbh_insert_hash
    dbh_select
    dbh_select_first
    dbh_select_as_list
    dbh_select_fetchone
    dbh_do
    dbh_list_tables
    dbh_selectall_arrayref
    dbh_sth_exec
    dbh_update_hash
    dbi_connect
    cond_where
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

    # query if input
    my $q = $ref->{q};

    # where ... AND statement
    my $w = $ref->{w} || {};

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

    $q ||= qq| 
        $SELECT $f FROM `$t` 
    |;

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
    my $q = qq| 
        $INSERT INTO `$t` ($f) VALUES ($ph) 
    |;
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
    my ($ref)=@_;

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
    my $q = qq| 
        $UPDATE `$t` SET $set
    |;

    my ($q_wh, $p_wh) = cond_where($w);

    $q .= $q_wh;

    my @p = ( @values_update, @$p_wh );
    my $ok = eval {$dbh->do($q,undef,@p); };
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


sub cond_where {
    my ($w,$sep) = @_;
    $sep ||= 'AND';

    my $e = q{`};

    my @fields_where = keys %$w;
    my @values_where = map { $w->{$_} } @fields_where;

    my $q = '';
    if (@values_where) {
        $q .= q{ WHERE } . join(sprintf(' %s ',$sep),map { $e . trim($_) . $e . ' = ? ' } @fields_where);
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

    my $dbfile = $ref->{dbfile};
    if($dbfile){ $dbh = dbi_connect($ref); }

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


    if ($ref->{close}) {
        if($dbfile && $dbh){
            eval { $dbh->disconnect; };
            if ($@) { $warn->($@); }
        }
    }

    return $FINE;
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
 

