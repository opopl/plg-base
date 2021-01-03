
package Base::H;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw( hash_inject );
use Base::DB qw(
    dbh_do
    dbh_insert_hash
    dbh_select
    dbh_select_as_list
    dbi_connect
    dbh_select_fetchone
);

use FindBin qw($Bin $Script);
use Getopt::Long qw(GetOptions);
use File::Spec::Functions qw(catfile);

use base qw(
    Base::Cmd
);


sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

      
sub get_opt {
    my ($self) = @_;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    my (@optstr, %opt);
    @optstr = ( 
        "cmd|c=s",
        "remote|r=s",
        "local|l=s",
        "dbfile=s",
        "html_root=s",
        "drop_tables",
    );
    
    unless( @ARGV ){ 
        $self->dhelp;
        exit 0;
    }else{
        GetOptions(\%opt,@optstr);
        $self->{opt} = \%opt;
    }

    foreach my $k (keys %opt) {
        $self->{$k} = $opt{$k};
    }

    return $self;   
}

sub dhelp {
    my ($self) = @_;

    my $s = qq{

    USAGE
        perl $Script OPTIONS
    OPTIONS
        -r      --remote        URL
        -l      --local         LOCAL
        -c      --cmd           CMD
                --dbfile        DBFILE, default: HTML_ROOT/urls.db
                --html_root     HTML_ROOT, root directory for storing saved html pages

                --reset_tables  Reset tables in DBFILE

    EXAMPLES
        perl $Script ...

    };

    print $s . "\n";

    return $self;   
}

sub init_db {
    my ($self) = @_;

    my $dbfile = $self->{dbfile} || catfile($self->{html_root},'urls.db');
        
    my $dbh = dbi_connect({ dbfile => $dbfile }); 
    return $self unless $dbh;

    $self->{dbh} = $dbh;
    
    my $qu = q{'};
    my $c  = q{,};
    my $ll = join $c => map { $qu.$_.$qu} qw( log warn debug );
    
    my @drop;
    
    if ($self->{reset_tables}) {
        push @drop,
            map { qq{ DROP TABLE IF EXISTS $_ } } qw(urls tags);
    }

    my @create;
    push @create,
        qq{
            CREATE TABLE IF NOT EXISTS urls (
                rid INTEGER UNIQUE,
                remote TEXT UNIQUE NOT NULL,
                local TEXT  UNIQUE NOT NULL,
                time_saved INTEGER NOT NULL,
                tags TEXT
            )
        },
        qq{
            CREATE TABLE IF NOT EXISTS tags (
                tag TEXT NOT NULL UNIQUE,
                rank INTEGER,
                rids TEXT
            )
        },
        ;

    my @queries;
    push @queries,
        @drop,@create;

    foreach my $q (@queries) {
        dbh_do({
            dbh  => $dbh,
            q    => $q,
        });
    }

    my @alter = ();
        push @alter, 
            #qq{ ALTER TABLE saved ADD COLUMN data TEXT},
            #qq{ ALTER TABLE saved ADD COLUMN doc_type TEXT},
        ;

    foreach my $q (@alter) {
        dbh_do({
            dbh  => $dbh,
            q    => $q,
            warn => sub {},
        });
    }


    $self;
}

sub _rid_free {
    my ($self) = @_;

    my $dbh = $self->{dbh};
    my $r = { 
        dbh => $dbh,
        q   => q{SELECT MAX(rid) FROM urls},
    };
    my $rid = dbh_select_fetchone($r) || 0;
    $rid++;
    return $rid;
}

sub cmd_fetch {
    my ($self) = @_;

    my $dbh = $self->{dbh};

    my $rid = $self->_rid_free();

    my $time_saved = time();

    my $h = {
        remote     => $self->{remote},
        local      => $self->{local},
        time_saved => $time_saved,
        rid        => $rid,
    };

    my $r_db = {
        dbh => $dbh,
        t   => 'urls',
        i   => q{INSERT OR REPLACE},
        h   => $h
    };
    dbh_insert_hash($r_db);

    return $self;
}

sub init {
    my ($self) = @_;
    
    #$self->SUPER::init();
    
    my $h = {
        html_root => $ENV{HTML_ROOT},
    };
        
    hash_inject($self, $h);
    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->get_opt
        ->init_db
        ->run_cmd
        ;

    return $self;
}

1;

