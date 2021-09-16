package Base::PerlFile;

=head1 NAME

Base::PerlFile - module for processing perl module (*.pm), script (*.pl) files

=cut

use strict;
use warnings;

use PPI;
use Clone qw(clone);

use File::Find qw( find );
use File::Slurp qw( write_file append_file );
use File::Path qw( rmtree );

use Data::Dumper;
use List::MoreUtils qw(uniq);
use Base::Arg qw(hash_inject);

use DBI;
use File::stat;

use Base::DB qw(
    dbh_do
    dbh_insert_hash
    dbh_select
    dbh_select_as_list
    dbh_select_fetchone
    dbh_update_hash
);

use base qw(
    Base::Logging
);

use vars qw( $DBH );

use constant QRS => ( 
        # select full subroutine name, e.g. PACKAGE::sub
        {   q => qq{ 
                SELECT 
                    `subname_full`, `filename`, `line_number`
                FROM
                    `tags`
                WHERE
                    `type` = ?
                    AND `filename` = ?
            },
            p => [qw( sub )],
        },
        # select short subroutine name, e.g. sub
        {   q => qq{ 
                SELECT 
                    `subname_short`, `filename`, `line_number`
                FROM
                    `tags`
                WHERE
                    `type` = ?
                    AND `filename` = ?
            },
            p => [qw( sub )],
        },
        # select package name
        {   q => qq{ 
                SELECT 
                    `namespace`, `filename`, `line_number`
                FROM
                    `tags`
                WHERE
                    `type` = ?
                    AND `filename` = ?
            },
            p => [qw( package )],
        },
        # select full variable declaration, e.g. @PACKAGE::var etc. declared as 'our'
        {   q => qq{ 
                SELECT 
                    `var_full`, `filename`, `line_number`
                FROM
                    `tags`
                WHERE
                    `type` = ?
                    AND `filename` = ?
            },
            p => [qw( var_our )],
        },
        # select short variable declaration, e.g. @var etc. declared as 'our'
        {   q => qq{ 
                SELECT 
                    `var_short`, `filename`, `line_number`
                FROM
                    `tags`
                WHERE
                    `type` = ?
                    AND `filename` = ?
            },
            p => [qw( var_our )],
        },

);

=head1 METHODS 

=cut

$Base::DB::WARN = sub { warn $_ for(@_); };

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}


=head2 subnames

=head3 Usage 

=cut

sub subnames {
    my ($self,$ref)=@_;

    # matching pattern
    my $pat = $ref->{pat} || '';

    my ($rows) = dbh_select({ 
        f => [qw(namespace subname_short)], 
        t => 'tags',
    });

    my $subnames = {};

    for my $row (@$rows){
        my $ns = $row->{namespace};

        my $subs = $subnames->{$ns} || [];

        my $sub = $row->{subname_short};
        next unless $sub;

        next unless $sub =~ /$pat/;

        push @$subs, $sub;
        $subnames->{$ns} = $subs;
    }
    foreach my $ns (keys %$subnames) {
        my $subs = $subnames->{$ns};
        @$subs = sort @$subs;
    }
    return $subnames;
}


=head2 namespaces

=head3 Usage 

=head3 Purpose

=cut

sub namespaces {
    my ($self, $ref)=@_;
    
    # matching pattern
    my $pat = $ref->{pat} || '';

    my ($rows) = dbh_select({ 
        f => [qw(namespace)], 
        t => 'tags',
    });

    my ($ns_h,$ns_a) = ( {}, [] );
    for my $row ( @$rows ){
        my $ns = $row->{namespace};

        next unless $ns;
        next unless $ns =~ /$pat/;
        next if $ns_h->{$ns};

        $ns_h->{$ns} = 1;
        push @$ns_a, $ns;
    }
    
    return $ns_a;
}



sub init_db {
    my $self = shift;

    my $dbfile = $self->{dbfile} || ':memory:';

    my $o = {
        PrintError       => 0,
        RaiseError       => 1,
        AutoCommit       => 1,
        FetchHashKeyName => 'NAME_lc',
    };

    $DBH = DBI->connect("dbi:SQLite:dbname=$dbfile","","",$o);

    $self->{dbh} = $Base::DB::DBH = $DBH;
    $Base::DB::WARN = sub { $self->_warn_([ @_ ]); };

    my @q;

###t_log
    push @q,
        qq{
            CREATE TABLE IF NOT EXISTS log (
                msg TEXT,
                time INTEGER,
                elapsed INTEGER,
                loglevel TEXT,
                func TEXT,
                prf TEXT
            );
        };

###t_files
    push @q,
        qq{
            CREATE TABLE IF NOT EXISTS `files` (
                `file` TEXT NOT NULL UNIQUE,
                `file_mtime` TEXT NOT NULL,
                `dir` TEXT NOT NULL,
                `done` INTEGER DEFAULT 0
            );
        },
    #push @q, qq{
            #ALTER TABLE `files` ADD COLUMN `done` INTEGER DEFAULT 0;
        #},
###t_tags
        qq{
            CREATE TABLE IF NOT EXISTS `tags` (
                `filename` TEXT,
                `file_mtime` TEXT,
                `dir` TEXT,
                `namespace` TEXT,
                `subname_short` TEXT,
                `subname_full` TEXT,
                `line_number` TEXT,
                `var_full` TEXT,
                `var_short` TEXT,
                `var_decl` TEXT,
                `var_parent_class` TEXT,
                `var_parent_lineno` int,
                `var_type` TEXT,
                `type` TEXT,
                `include_module` TEXT,
                `include_arguments` TEXT,
                `content` TEXT
            );
        },
###t_taglocs
        qq{
            create table if not exists `taglocs` (
                `tag` TEXT,
                `file` TEXT,
                `address` TEXT
            );
        },
        ;
    
    foreach my $q (@q) {
        eval { dbh_do({ q => $q }); };
    }

    return $self;
}

sub init {
    my ($self) = @_;

    my $h = {
        exts => [qw(pl pm t)],
        add  => [qw(
                include
                packages 
                subs 
                vars 
        )],
    };
        
    hash_inject($self, $h);

    $self->init_db;

    return $self;
        
}

sub db_drop_tables {
    my ($self) = @_;

    my (@drop, @tables_drop);

    push @tables_drop,
        qw(files),
        qw(tags),
        qw(taglocs),
        qw(log),
        ;
    ;
    push @drop, map { qq{DROP TABLE IF EXISTS `$_`} } @tables_drop;

    foreach my $q (@drop) {
        eval { dbh_do({ q => $q }); };
    }

    return $self;
}

=head2 db_add_file

=head3 Purpose

Add file + related info (modification times etc.) to table C<files>.

=head3 Usage

    $pf->db_add_file($file);

    $pf->db_add_file($file, $dir);

=cut

sub db_add_file {
    my($self, $file, $dir) = @_;

    $dir ||= '';

    my ( $st, $file_mtime );
    $st         = stat($file);
    $file_mtime = $st->mtime;

    my $h = {
        file       => $file,
        file_mtime => $file_mtime,
        dir        => $dir,
    };

    dbh_insert_hash({
        i => 'INSERT OR IGNORE',
        t => 'files',
        h => $h,
    });

    return $self;
}

=head2 load_files_from_fs

=head3 Usage

=head4 No arguments

    #   dirs, exts are stored as 
    #       $pf->{dirs}, $pf->{exts}
    $pf->load_files_from_fs;

=head4 With arguments

    $pf->load_files_from_fs({ exts => [ 'pm'] });

    $pf->load_files_from_fs({ 
        exts => [ 'pm'], 
        dirs => [ $dir1, $dir2 ]  
    });

=head3 Purpose

Given the list of extensions C<exts> and directories C<dirs>,
give the list of files and insert it then into C<files> table, together
with files' modification times stored as table field C<file_mtime>.

=head3 Returns

C<$self>.

=head3 Call tree

    db_add_file

=cut

sub load_files_from_fs {
    my($self, $ref) = @_;

    my $d = $ref->{dirs} || $self->{dirs} || [];
    my $e = $ref->{exts} || $self->{exts} || [];
    my $f = $ref->{files} || $self->{files} || [];

    my @dirs = uniq(@$d);
    my @exts = uniq(@$e);

    my @files = grep { -e } uniq(@$f);

    foreach my $file (@files) {
        $self->db_add_file($file, '');
    }
    
    foreach my $dir (@dirs) {
        next unless $dir;
        next unless -d $dir;

        find({ 
            preprocess => sub { @_ },
            wanted => sub { 
                return unless -f;
                foreach my $ext (@exts) {
                    if (/\.$ext$/) {
                        my $file = $File::Find::name;

                        $self->db_add_file($file, $dir);

                        last;
                    }
                }
            } 
        },$dir
        );
    }

    $self;
}

=head2 process_var

=head3 Usage

    $pf->process_var($node,@a);

=cut

sub process_var {
    my ($self,$node,@a)=@_;

    my ($ns,$file,$type,$file_mtime) = @a;

    unless ($file_mtime) {
        my $st = stat($file);
        $file_mtime = $st->mtime;
    }

    $ns ||= 'main';
    @a = ($ns,$file,$type,$file_mtime);

    my @tokens = $node->children;

    foreach my $token ( @tokens )
    {
        # list or expression - searching recursively:
        $self->process_var( $token, @a ), next if $token->class eq 'PPI::Structure::List';
        $self->process_var( $token, @a ), next if $token->class eq 'PPI::Statement::Expression';
          
        if ( $token->class eq 'PPI::Token::Symbol'){
            my $var = $token->content;
            my $var_full = $ns . '::' . $var;

            my $sign    = $token->symbol_type;
            my $varname = $var;

            $var_full = $sign  . $ns . '::' . $varname;

            my $h = {
                'filename'    => $file,
                'file_mtime'  => $file_mtime,
                'line_number' => $node->line_number,
                'var_type'    => $type,
                'var_short'   => $var,
                'var_full'    => $var_full,
                #'var_decl'   => $node->content,
                'var_parent_class'    => $node->parent->class,
                'var_parent_lineno'   => $node->parent->line_number,
                'namespace'   => $ns,
                'type'        => 'var_' . ( $type || 'undef' ),
            };
    
            dbh_insert_hash({ h => $h, t => 'tags' });
        }

    }
    $self;
}


=head2 files_from_db

=head3 Usage

    my $files = $pf->files_from_db;

    my $files = $pf->files_from_db({ redo_files => 1 });

=cut

sub files_from_db {
    my ($self, $ref) = @_;

    my $redo_files = $ref->{redo_files} || $self->{redo_files} || 0;

    my $files_limit = $self->{files_limit} || 0;

    my $cond = '';
    unless($redo_files) {
        $cond = q{ WHERE done IS NOT 1 };
    }

    if ($files_limit) {
        $cond .= qq{ LIMIT $files_limit }; 
    }

    my $r = { 
        q    => q{ SELECT file, file_mtime FROM files },
        cond => $cond,
    };
    my ($rows) = dbh_select($r);
    $self->{filelist} = [ map { $_->{file} } @$rows ];

    return $rows;
}

=head2 ppi_process

=head3 Usage

=head4 no options

    $pf->ppi_process;

    # files to be processed are 
    #   obtained from $pf->files_from_db() invocation

=head4 'files' option (ARRAYREF)

    Process an array of files via PPI

    $pf->ppi_process({ files => $files });

=head4 'file' option (SCALAR)

    Process a single file via PPI

    $pf->ppi_process({ 
        file => $file,

        # optional, file modification time
        file_mtime => $file_mtime,
     });

=head3 Flags

=head4 'redo_files' flag (values: 0 or 1, default: 0)

=cut

sub ppi_process {
    my ($self, $ref) = @_;

    my $redo_files = $ref->{redo_files} || $self->{redo_files} || 0;

    my ($file, $file_mtime) = @{$ref}{qw(file file_mtime)};

    my $files;

    if ($file){
        $files = [];
    } else {
        $files = $ref->{files} || $self->files_from_db || [];
    }

    if (@$files) {
        my $nfiles = scalar @$files;
        $self->debug({ 'msg' => 'Files to process: ' . $nfiles });
        my $start = time();

        my ($i, $nleft) = (1, $nfiles);

        my $elapsed;

        foreach my $f (@$files) {
            $nleft = $nfiles - $i;

            my $start_f = time();
            $elapsed = $start_f - $start;

            $self->ppi_process($f);

            my $end_f = time();
            my $delta = $end_f - $start_f;

            $self->debug([ 
                { 
                    msg => sprintf(' files left: %s elapsed: %s', $nleft, $elapsed),  
                    ih => { 
                        elapsed => $elapsed 
                    } 
                } ]);

            $i++;
        }
    }

    unless ($file && -f $file) { return $self; }

    unless ($file_mtime) {
        my $st = stat($file);
        $file_mtime = $st->mtime;
    }

    my ($mtime_db, $done) = dbh_select_as_list({
        s    => q{SELECT},
        f    => [qw(file_mtime done)],
        t    => 'files',
        cond => qq{ WHERE file = ? },
        p    => [$file],
    });

    unless($redo_files){
        # if we are not forcing redo, then:
        #   file is NOT modified compared to its data stored in database,
        #       so no need for further actions
        #   OR:
        #       done = 1 in the database
        if ( (defined $mtime_db && ($file_mtime == $mtime_db) ) || ($done) ) {
            return $self;
        }
    }

    # file is modified, so process it via PPI
    #

    my $DOC = eval { PPI::Document->new($file); };
    if ($@) { $self->_warn_([ $@ ]); return $self; }

    $DOC->index_locations;

    my $f = sub { 
        $_[1]->isa( 'PPI::Statement::Sub' ) 
        || $_[1]->isa( 'PPI::Statement::Package' )
        || $_[1]->isa( 'PPI::Statement::Variable' )
        || $_[1]->isa( 'PPI::Statement::Include' )
    };
    my @nodes = @{ $DOC->find( $f ) || [] };

    my $ns;

    my $node_count = 0;
    my $max_node_count = $self->{max_node_count};

    my $add = { map { $_ => 1 } @{$self->{add} || []} };

    for my $node (@nodes){

        $node_count++;
        last if ( $max_node_count && ( $node_count == $max_node_count ) );

###PPI_Statement_Sub
        $node->isa( 'PPI::Statement::Sub' ) && do { 
            next unless $add->{subs};
                $ns ||= 'main'; 

                my $h = { 
                        'filename'             => $file,
                        'file_mtime'           => $file_mtime,
                        'line_number'          => $node->line_number,
                        ######################
                        'subname_full'         => $ns . '::' . $node->name,
                        'subname_short'        => $node->name,
                        'namespace'            => $ns,
                        'type'                 => 'sub',
                };

                dbh_insert_hash({ h => $h, t => 'tags' });

        };
###PPI_Statement_Variable
        $node->isa( 'PPI::Statement::Variable' ) && do { 
            next unless $add->{vars};

            my $type = $node->type;
            next unless $type eq 'our';

            my @a = ($ns,$file,$type);

            my $vars = [ $node->variables ];

            $self->process_var($node,@a);
        };
###PPI_Statement_Include
        $node->isa( 'PPI::Statement::Include' ) && do { 
            next unless $add->{include};

            my $type = $node->type;

            my @a = $node->arguments;
            my $a = join(' ',@a);
            my $module = $node->module;

            my $h = { 
                    'filename'    => $file,
                    'file_mtime'  => $file_mtime,
                    'line_number' => $node->line_number,
                    ######################
                    'namespace'         => $ns,
                    'type'              => 'include_' . $node->type,
                    'include_module'    => $module ,
                    'include_arguments' => $a,
            };
    
            dbh_insert_hash({ h => $h, t => 'tags' });

            if ($module eq 'vars') {
                local $_ = $a;
                my @v;

                /^\s*qw\((.*)\)/ms && do { @v = map { ($_) ? $_ : () } split /\s+/, $1;  };

                my $pat = qr/([\$\@\%])(\w+)$/;
                for (@v){
                    my ($sign,$varname) = ( /$pat/g );

                    unless (defined $sign) {
                        $self->_warn_([ 'PPI::Statement::Include: $sign zero!' ]);
                    }

                    my $h = { 
                            'filename'    => $file,
                            'file_mtime'  => $file_mtime,
                            'line_number' => $node->line_number,
                            ######################
                            'namespace'   => $ns,
                            'type'        => 'var_our',
                            'var_short'   => $_,
                            'var_full'    => ( $sign || '' ). $ns . '::' . $varname,
                    };
    
                    dbh_insert_hash({ h => $h, t => 'tags' });
                }
            }

        };
###PPI_Statement_Package
        $node->isa( 'PPI::Statement::Package' ) && do { 
            $ns = $node->namespace; 

            next unless $add->{packs};

            my $h = { 
                'filename'    => $file,
                'file_mtime'  => $file_mtime,
                'line_number' => $node->line_number,
                ######################
                'namespace'   => $ns,
                'type'        => 'package',
            };

            dbh_insert_hash({ h => $h, t => 'tags' });
        };
    }

    dbh_update_hash({ 
        h => { done => 1 }, 
        u => q{UPDATE},
        t => 'files',
        w => { file => $file },
    });

    return $self;
}

=head2 write_to_tagfile

=head3 Usage 

    my $ref = {
        # full path to the tagfile which will be written
        tagfile => $tagfile,

        add => $add,

        filelist => $filelist,
    };

    # $pf is a Base::PerlFile instance
    $pf->write_to_tagfile($ref);

=cut

sub write_to_tagfile {
    my ( $self, $ref ) = @_;

    $ref ||= {};

    my $tagfile = $ref->{tagfile} || $self->{tagfile} || '';
    unless ($tagfile) {
        return $self;
    }

    $self->log({ msg => 'write_to_tagfile: ' . $tagfile });

    my $add = $ref->{add} || $self->{add} || [];

    my $file     = $ref->{file};
    my $filelist = $ref->{filelist} || $self->{filelist} || [];

    $filelist = [] if $file;
    $file = '' if @$filelist;

    if (@$filelist) {
        my $r = { %$ref };
        $r->{filelist} = [];

        dbh_do({ q => q{ 
            DELETE FROM `taglocs`
        }});

        foreach my $file (@$filelist) {
            $r->{file} = $file;
            $r->{lines_pre} = [];

            $self->write_to_tagfile($r);
        }
        return $self;
    }
    my $queries = clone([ QRS ]);

    foreach my $qs (@$queries) {
        push @{$qs->{p}}, $file;
    }

    if (my $ns = $self->{ns}) {

        foreach my $qs (@$queries) {
            $qs->{q} .= qq{ AND `namespace` = ? };
            push @{$qs->{p}},$ns;
        }
    }

    $self->tagloc_add({ queries => $queries });

    my $q = q{
        SELECT 
            `tag`, `file`, `address`
        FROM 
            `taglocs`
        WHERE
            `file` = ?
        ORDER BY 
            `tag`
        ASC
    };
    
    my ($rows) = dbh_select({
        q     => $q,
        fetch => 'fetchrow_arrayref',
        p     => [$file],
    });

    my @lines;
    my @pre = @{ $ref->{lines_pre} || [] };
    push @lines, @pre;

    for my $row ( @$rows ){
        push @lines, join( "\t", @$row );
    }


    append_file($tagfile, join("\n", @lines) . "\n");

    return $self;
}

=head2 generate_from_fs

=cut

sub generate_from_fs {
    my ($self) = @_;

    $self
        ->load_files_from_fs
        ->generate_from_db
        ;
    
    return $self;
}

=head2 generate_from_db

=cut

sub generate_from_db {
    my ($self) = @_;

    $self
        ->ppi_process
        ->tagfile_rm
        ->write_to_tagfile
        ;
    
    return $self;
}

sub tagfile_rm {
    my ($self,$ref) = @_;

    my $tagfile = $ref->{tagfile} || $self->{tagfile} || '';
    rmtree $tagfile if -e $tagfile;

    return $self;
}

=head2 tagloc_add

=head3 Usage

    # single query:
    $pf->tagloc_add({ 
        tagfile => $tagfile,
        query => q{...},
        params => [...],
    });

    # iterate over queries:
    my $queries = [ { q => q{...}, p => [...] }, { ... }, ];

    $pf->tagloc_add({ 
        tagfile => $tagfile,
        queries => $queries,
    });

=cut

sub tagloc_add {
    my ($self, $ref )=@_;

    $ref ||= {};

    my ( $query, $queries, $params ) = @{$ref}{qw( query queries params )};

    my $tagfile = $ref->{tagfile} || $self->{tagfile} || '';

    $queries = [] if ($query);
    if ($queries && @$queries) {
        foreach my $q (@$queries) {
            $self->tagloc_add({ 
                query  => $q->{q},
                params => $q->{p},
            });
        }
        return $self;
    }

    $self->debug({ msg => 'tagloc_add: ' , ih => { dump => Dumper($ref) } });

    my ( $rows ) = dbh_select({
        q     => $query,
        p     => $params,
        fetch => 'fetchrow_arrayref',
    });

    #print Dumper($query) . "\n";
    #print Dumper($params) . "\n";
    #print Dumper($rows) . "\n";

    foreach my $row (@$rows) {
        my @v = @$row;

        my $q = q{
            INSERT OR REPLACE INTO 
                `taglocs` ( `tag`, `file`, `address` )
            VALUES 
                (?, ?, ?)
        };
        dbh_do({ 
            q => $q, 
            p => [@v],
        });
    }

    return $self;
}


1;
 

