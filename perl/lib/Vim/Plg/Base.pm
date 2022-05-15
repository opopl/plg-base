
package Vim::Plg::Base;

=head1 NAME

Vim::Plg::Base

=cut

use strict;
use warnings;

use File::Spec::Functions qw(catfile);
use File::Dat::Utils qw(readarr);
use File::Basename qw(basename dirname);
use File::Slurp qw(read_file);

use Getopt::Long qw(GetOptions);

use File::Find;
use File::Find::Rule;

use Data::Dumper;

use Vim::Perl qw(VimMsg);

use DBD::SQLite;
use DBI;

use FindBin qw($Bin $Script);

use Base::Arg qw( 
    hash_inject
    hash_update
);

use Base::DB qw(
    dbh_insert_hash
    dbh_select
    dbh_select_as_list
    dbh_do
);

use base qw( 
    Class::Accessor::Complex 
    Base::Logging
);

use File::Path qw(mkpath);
use File::stat qw(stat);

our @TYPES = qw( list dict listlines );


=head1 SYNOPSIS

    my $plgbase = Vim::Plg::Base->new;

=head1 METHODS

=cut

=head2 init 

=over

=item Usage

=back

=cut

sub init {
    my $self=shift;

    #return unless $^O eq 'MSWin32';
    $DB::single = 1;

    $self
        ->init_dirs
        ->init_sqlstm
        ->init_vars
        #  ---------------------
        ->get_opt
        #  ---------------------
        ->db_connect
        ->db_drop_tables
        ->db_create_tables
        ->init_dat;

    $self;

}

sub get_opt {
    my ($self) = @_;

    return $self unless $self->{do_get_opt};
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    my (@optstr, %opt);

    @optstr = ( 
        # image file, pattern, or directory
        "add|a=s@",
        # config
        "config|c=s@",
        # tex file
        "file|f=s",
        "proj|p=s",
        "root|r=s",
        "sec|s=s",
        # e.g. load_file
        "cmd|c=s",
        "reset",
        "reload",
        "debug|d",
        # queries to img.db
        "query|q=s",
        "param=s@",
    );
    
    unless( @ARGV ){ 
        $self->print_help;
        exit 0;
    }else{
        GetOptions(\%opt,@optstr);
        $self->{opt} = \%opt;
    }

    hash_update($self, \%opt);

    if ($self->{add}) {
        $self->{cmd} = 'add_images';
    }

    return $self;    
}

sub print_help {
    my ($self) = @_;

    my $pack = __PACKAGE__;
    print qq{
        ENVIRONMENT:
            IMG_ROOT   $ENV{IMG_ROOT}
            HTML_ROOT  $ENV{HTML_ROOT}
            PLG        $ENV{PLG}
        SEE ALSO:
            base#bufact#tex#list_img 
            BufAct list_img
        PACKAGES:
            $pack
            Plg::Projs::GetImg::Fetcher
        LOCATION:
            $0
        OPTIONS:
            --add -a string (TODO) add image file, pattern or directory

            --file -f FILE string TeX file with urls
            --proj -p PROJ string
            --root -r ROOT string
            --sec  -s SEC  string

            --cmd  -c CMD  string    e.g. load_file

            --reset (DISABLED) reset database, remove image files
            --reload

            --debug -d
        
            # queries to img.db
            --query -q QUERY string
            --param PARAMS
        USAGE:
            PROCESS SINGLE TEX-FILE:
                perl $Script -f TEXFILE 
                perl $Script --file TEXFILE 
            PROCESS WHOLE PROJECT:
                perl $Script -p PROJ -r ROOT 
            DEBUGGING:
                perl $Script -p PROJ -r ROOT -d
                perl $Script -p PROJ -r ROOT --debug
            QUERY IMAGE DATABASE:
                perl $Script --cmd query -q "select count(*) from imgs" 
                perl $Script --cmd query 
                    --query "select count(*) from imgs where url = ? " 
                    --param URL
    } . "\n";
    exit 0;

    return $self;
}



sub init_vars {
    my $self=shift;

    my $dat = catfile($self->dirs('plgroot'),qw( data list db_table_order.i.dat ));

    my $tb_order = (-e $dat) ? readarr($dat) : [];

    my $h = {
        withvim      => $self->_withvim(),
        dbfile       => ':memory:',
        dattypes     => [@TYPES],
        dbopts       => {
            tb_reset => {},
            tb_order => $tb_order,
        },

    };

    my @k = keys %$h;

    for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

    $self;
}

=head3 init_sqlstm

=head4 Purpose

Load SQL statements from C<$plg/base/data/sql> directory

=head4 Usage

    $plgbase->init_sqlstm;

=cut

sub init_sqlstm {
    my ($self) = @_;

    my $sql_dir = catfile($self->dirs('plgroot'),qw(data sql));
    
    my @files;
    my @exts=qw(sql);
    my @dirs;
    push @dirs,$sql_dir;
    
    my $h = { sqlstm => {}};
    File::Find::find({ 
        wanted => sub { 
            foreach my $ext (@exts) {
                if (/\.$ext$/) {
                    s/\.$ext$//g;
    
                    my $f   = $File::Find::name;
                    my $sql = read_file($f);

                    $h->{sqlstm}->{$_} = $sql;
                }
            }
        } 
    },@dirs
    );

        
    my @k = keys %$h;

    for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

    $self;
}

sub init_dirs {
    my $self = shift;

    my $dirs = {
        plgroot => catfile($ENV{VIMRUNTIME},qw(plg base)),
        appdata => catfile($ENV{APPDATA},qw(vim plg base)),
    };

    my $d = $dirs->{appdata};
    mkpath $d unless -d $d;

    foreach my $type (@TYPES) {
        $dirs->{'dat_'.$type} = catfile($dirs->{plgroot},qw(data),$type);
    }
    $self->dirs($dirs);

    $self;
}

sub db_connect {
    my ($self) = @_;

    my $dbfile  = $self->dbfile;
    my $dbname = basename($dbfile);
    $dbname =~ s/\.(\w+)//g;
    
    if ($self->dbh) {
        eval { $self->dbh->disconnect;  };
        if ($@) { 
            my @w;
            push @w, 'Failure to disconnect db:', DBI->errstr, $@ ;
                
            $self->_warn_([ @w ]); 
        }
    }

    my $dbh;

    $self->debug([ 'sqlite connect:',$dbfile ]);
    
    my $o={
        PrintError       => 1,
        RaiseError       => 1,
        AutoCommit       => 1,
        FetchHashKeyName => 'NAME_lc',
    };
    eval { $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","",$o); };
    if ($@) { 
        my @w;
        push @w, 
            'Failure to connect to database with dbname:',$dbname,
            DBI->errstr,$@;
        $self->_warn_([@w]); return $self; 
    }

    unless ($dbh) {
        $self->_warn_(['dbh undefined!']);
    }else{
        $self->dbh($dbh);
        $self->dbname($dbname);
        $Base::DB::DBH  = $dbh;

        if (my $s = $self->{sub_on_connect}) {
            $s->($dbh);
        }
    }

    $Base::DB::WARN = sub{ $self->_warn_([@_]) };

    $self;
}

sub update_self {
    my ($self,%o) = @_;

    foreach my $k (keys %o) {
        $self->{$k} = $o{$k};
    }
    $self;
}

sub reload_from_fs {
    my ($self) = @_;

    my $tb_order = [qw(
        plugins 
        plugins_all 
        datfiles
    )];
    my $tb_reset = map { ($_ => 1 ) } @$tb_order;

    my %o = (
        dbopts       => {
            tb_reset => $tb_reset,
            tb_order => $tb_order,
        },
    );

    $self
        ->update_self(%o)
        ->db_connect
        ->db_drop_tables
        ->db_create_tables
        ->init_dat;

    $self;
}

sub _withvim {
    my $self=shift;

    eval 'VIM::Eval("1")';
    
    my $uv = ($@) ? 0 : 1;
    return $uv;
}

=head2 dat_locate_from_fs 

=head3 Usage

    my $ref={
        type    => TYPE (string, one of of: list,dict,listlines - stored in dattypes array),
        plugin  => PLUGIN (string ),
        prefix  => PREFIX (string ),
    };

    $plgbase->dat_locate_from_fs($ref);

=head3 Purpose

=cut

sub dat_locate_from_fs {
    my ($self,$ref) = @_;

    my @dirs   = grep { (-d $_) } @{$ref->{dirs} || []};
    return unless @dirs;

    my $prefix = $ref->{prefix} || '';
    my $type   = $ref->{type} || '';
    my $plugin = $ref->{plugin} || 'base';
    $DB::single = 1;

    my $pat  = qr/\.i\.dat$/;
    File::Find::find({ 
        wanted => sub { 
            my $name = $File::Find::name;
            my $dir  = $File::Find::dir;

            /$pat/ && do {
                    s/$pat//g;
                    my $kfull = ($prefix) ? join("_",$prefix,$_) : $_;
                    print qq{$kfull} . "\n";

                    dbh_insert_hash({
                        t => 'datfiles',
                        h => {
                            key     => $_,
                            keyfull => $kfull,
                            type    => $type,
                            plugin  => $plugin,
                            datfile => $name,
                        }
                    });
            };
             
        } 
    },@dirs
    );
}

=head2 db_list_plugins 

=head3 Usage

    my @plugins = $plgbase->db_list_plugins();

=head3 Purpose

=cut

sub db_list_plugins {
    my $self=shift;

    my $dbh = $self->dbh;
    my $r   = $dbh->selectall_arrayref('select plugin from plugins');
    my @p   = map { $_->[0] } @$r;

    wantarray ? @p : \@p ;
}

sub db_tables {
    my $self=shift;


    my $q = qq{  
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

    my ($rows) = dbh_select({ 
        q    => $q,
    });

    my @tables = map { $_->{name} }  @$rows;

    wantarray ? @tables : \@tables ;
}

sub db_table_exists {
    my ($self, $tb) = @_;

    my %tables = map { (defined $_) ? ($_ => 1 ) : () } $self->db_tables;
    my $ex = $tables{$tb} ? 1 : 0;

    return $ex;

}

sub db_table_empty {
    my ($self, $tb) = @_;

    my $q = qq{select * from $tb limit 1};

    my ($rows) = dbh_select({ q => $q });

    return (@$rows) ? 0 : 1;

}

=head2 db_dbfile_size

=over

=item Usage

    my $size = $plgbase->db_dbfile_size();

=back

=cut

sub db_dbfile_size {
    my $self=shift;

    my $dbfile =  $self->dbfile;

    my $st;
    eval{ $st = stat($dbfile)};
    $@ && do { $self->_warn_([ "File::stat errors for $dbfile: $@" ]); return; };

    my $size=$st->size;
    return $size;
}



=head2 db_drop_tables 

=head3 Usage

    $plgbase->db_drop_tables({ tb_reset => { ... }});

=head3 Purpose

=cut

sub db_drop_tables {
    my ($self,$ref) = @_;

    $ref ||= {};

    my $dbopts = $ref->{dbopts} || $self->dbopts;

    # which tables to drop 
    my $tb_reset=$ref->{tb_reset} || $dbopts->{tb_reset} || {};

    # order of tables to be dropped
    my $tb_order=$ref->{tb_order} || $dbopts->{tb_order} || [];

    my $dbh = $self->dbh;

    my @drop;
    foreach my $tb (@$tb_order) {
        if ($ref->{all} || $tb_reset->{$tb}) {
            push @drop, qq{ DROP TABLE IF EXISTS $tb; };
        }
    }

    for my $q (@drop){
        dbh_do({ q  => $q });
    }

    $self;
}

sub db_create_tables {
    my ($self)=@_;

    my $dbopts = $self->dbopts;

    my $tb_reset = $dbopts->{tb_reset} || {};
    my $tb_order = $dbopts->{tb_order} || [];

    my $dbh = $self->dbh;

    my @create;
    foreach my $tb (@$tb_order) {
        push @create,$self->sqlstm('create_table_'.$tb);
        
        unless ($self->db_table_exists($tb)) {
            $tb_reset->{$tb}=1;
        }
    }

    for my $q (@create){
        dbh_do({ q    => $q });
    }

    dbh_insert_hash({
        i => q{INSERT OR IGNORE},
        t => 'dbfiles',
        h => {
            dbfile   => $self->dbfile,
            dbname   => $self->dbname,
            dbdriver => 'sqlite',
        }
    });

    $self;
}


=head2 init_dat_base 

=head3 Usage

    $plgbase->init_dat_base();

=head3 Purpose

    Fill datfiles hash either from FS (if one resets "datfiles" table) or from the database

=cut

sub init_dat_base {
    my $self=shift;

    my @types    = $self->dattypes;
    my $dbopts   = $self->dbopts_ref;

    my $tb_reset = $dbopts->{tb_reset} || {};

    if ($tb_reset->{datfiles} || $self->db_table_empty('datfiles')) {
        $tb_reset->{datfiles} ||= 1;
        $self->dbopts(tb_reset => $tb_reset);

        # find all *.i.dat files in base plugin directory
        foreach my $type (@types) {
            my $dir = $self->{dirs}->{'dat_'.$type};
            next unless -d $dir;
    
            $self->dat_locate_from_fs({
                dirs   => [$dir],
                type   => $type,
                prefix => '',
                plugin => 'base',
            });
        }
    }
    $self;
}

sub init_dat_plugins {
    my ($self) = @_;

    my @types   = $self->dattypes;

    my $dbopts   = $self->dbopts_ref;
    my $tb_reset = $dbopts->{tb_reset} || {};

    my @plugins = dbh_select_as_list({ 
        t => 'plugins', 
        f => [qw(plugin)],
    });

    my @other = dbh_select_as_list({
        t    => 'datfiles',
        s    => 'select distinct',
        f    => [qw(plugin)],
        cond => qq{where plugin not in (?)},
        p    => [qw(base)],
    });

    if ($tb_reset->{datfiles} || (not @other) ) {
        # find all *.i.dat files for the rest of plugins, except  base plugin
        foreach my $p (@plugins) {
            next if $p eq 'base';

            foreach my $type (@types) {
                my $pdir = catfile($ENV{VIMRUNTIME},qw(plg),$p,qw(data),$type);
                $self->dat_locate_from_fs({ 
                    dirs   => [$pdir],
                    type   => $type,
                    plugin => $p,
                    prefix => $p, 
                });
            }
        }
    }

}

sub init_plugins {
    my ($self)=@_;

    my ($rows) = dbh_select({ 
        q => q{ select datfile from datfiles where key = ? },
        p => [qw(plugins)],
    });
    my ($dat_plg) = map { $_->{datfile} } @$rows;

    #print $dat_plg . "\n";

    unless ($dat_plg) {
        $self->_warn_([ 'plugins DAT file NOT defined!!' ]);
    }
    if (-e $dat_plg) {
        my @plugins = readarr($dat_plg);
    
        for(@plugins){  
            dbh_insert_hash({
                i => 'INSERT OR IGNORE',
                t => 'plugins', 
                h => { plugin => $_ }
            });
        }
    }

    $self;

}

sub init_plugins_all {
    my ($self) = @_;
    
    my @dirs;
    push @dirs,
        catfile($self->dirs('plgroot'),qw(..));

    # list of all plugins
    my $r = File::Find::Rule->new;

    my @pall = $r
        ->directory
        ->relative
        ->maxdepth(1)
        ->in( @dirs );

    for(@pall){
        dbh_insert_hash({
            i => q{INSERT OR IGNORE},
            t => 'plugins_all',
            h => {
                plugin => $_,
            },
        });
    }
    
    $self;
}

sub init_dat {
    my $self = shift;

    $DB::single = 1;

    $self
        ->init_dat_base
        ->init_plugins
        ->init_plugins_all
        ->init_dat_plugins
        ;

    $self;

}

BEGIN {
    ###__ACCESSORS_SCALAR
    our @scalar_accessors = qw(
        do_get_opt
        dbh
        sth
        dbfile
        dbname
        withvim
        sub_warn
        sub_log
        sub_on_connect
        def_PRINT
        def_WARN
        prepared_query
    );
    
    ###__ACCESSORS_HASH
    our @hash_accessors=qw(
        dirs
        vars
        dbopts
        done
        sqlstm
    );
    
    ###__ACCESSORS_ARRAY
    our @array_accessors=qw(
        dattypes
    );

    __PACKAGE__
        ->mk_scalar_accessors(@scalar_accessors)
        ->mk_array_accessors(@array_accessors)
        ->mk_hash_accessors(@hash_accessors)
        ->mk_new;

}

1;
 

