package Base::PerlFile;

use strict;
use warnings;

use PPI;

use File::Find qw( find );
use File::Slurp qw( write_file append_file );
use File::Path qw(rmtree);
use Data::Dumper;

use Base::DB;

use DBI;

our $dbh;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub warn {
	my ($self,@args)=@_;

	my $sub = $self->{sub_warn} || $self->{sub_log} ||undef;
	$sub && $sub->(@args);

	return $self;
}

sub log {
	my ($self,@args)=@_;

	my $sub = $self->{sub_log} ||undef;
	$sub && $sub->(@args);

	return $self;
}

sub init_db {
	my $self=shift;

	$dbh = DBI->connect("dbi:SQLite:dbname=:memory:","","");

	$Base::DB::dbh=$dbh;

	my @q;
	push @q,
		qq{
			create table `tags` (
				`id` int auto_increment,
				`filename` varchar(1024),
				`namespace` varchar(1024),
				`subname_short` varchar(1024),
				`subname_full` varchar(1024),
				`line_number` varchar(1024),
				`var_full` varchar(1024),
				`var_short` varchar(1024),
				`var_decl` varchar(1024),
				`var_parent_class` varchar(1024),
				`var_parent_lineno` int,
				`var_type` varchar(1024),
				`type` varchar(1024),
				`content` text,
				primary key(`id`)
			);
		},
		qq{
			create table `tags_write` (
				`id` int auto_increment,
				`tag` varchar(1024),
				`file` varchar(1024),
				`address` varchar(1024),
				primary key(`id`)
			);
		},
		;
	
	foreach my $q (@q) {
		$dbh->do($q);
	}

	return $self;
}

sub init {
	my $self=shift;

	my $h={
		exts => [qw(pl pm t)],
		add  => [qw(subs packages)],
	};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self->init_db;

	return $self;

		
}

sub load_files_source {
	my($self,$ref)=@_;

	my $dirs = $ref->{dirs} || $self->{dirs} || [];
	my $exts = $ref->{exts} || $self->{exts} || [];

	my @files;
	
	foreach my $dir (@$dirs) {
		next unless -d $dir;
		#chdir $dir;

		find({ 
			preprocess => sub { @_ },
			wanted => sub { 
				return unless -f;
				foreach my $ext (@$exts) {
					if (/\.$ext$/) {
						push @files,$File::Find::name;
						last;
					}
				}
			} 
		},$dir
		);
	}

	$self->{files_source}=[@files];

	$self;
}

sub process_var {
	my ($self,$node,@a)=@_;

	my ($ns,$file,$type) = @a;

	$ns ||= 'main';
	@a = ($ns,$file,$type);

    my @tokens = $node->children;

    foreach my $token ( @tokens )
    {
        # список или выражение - ищем имена рекурсивно:
        $self->process_var( $token,@a ), next if $token->class eq 'PPI::Structure::List';
        $self->process_var( $token,@a ), next if $token->class eq 'PPI::Statement::Expression';
          
		if ( $token->class eq 'PPI::Token::Symbol'){
			my $var = $token->content;
			my $h = {
				'filename'    => $file,
				'line_number' => $node->line_number,
				'var_type'	  => $type,
				'var_short'	  => $var,
				'var_full'	  => $ns . '::' . $var,
				#'var_decl'	  => $node->content,
				'var_parent_class'	  => $node->parent->class,
				'var_parent_lineno'	  => $node->parent->line_number,
				'namespace'   => $ns,
				'type'   	  => 'var_'.( $type || 'undef' ),
			};
			$self->log(Dumper($h));
	
			$self->dbh_insert_hash({ h => $h });
		}

    }
	$self;
}

sub ppi_list_subs {
	my ($self,$ref)=@_;

	my $files = $ref->{files} || $self->{files_source} || [];

	my $file = $ref->{file};

	$files=[] if $file;

	if (@$files) {
		foreach my $file (@$files) {
			$self->ppi_list_subs({ file => $file });
		}
	}

	unless ($file && -f $file) { return $self; }

	$self->log('ppi_list_subs: ' . Dumper($ref));

 	my $DOC; 
	
	eval { $DOC = PPI::Document->new($file); };
	if ($@) { $self->warn($@); return $self; }

	$DOC->index_locations;

	my $f = sub { 
		$_[1]->isa( 'PPI::Statement::Sub' ) 
		|| $_[1]->isa( 'PPI::Statement::Package' )
		|| $_[1]->isa( 'PPI::Statement::Variable' )
	};
	my @nodes = @{ $DOC->find( $f ) || [] };

	my $ns;

	my $node_count = 0;
	my $max_node_count = $self->{max_node_count};

	my $add = { map { $_ => 1 } @{$self->{add} || []} };

	for my $node (@nodes){
		$node_count++;
		last if ( $max_node_count && ( $node_count == $max_node_count ) );

		$node->isa( 'PPI::Statement::Sub' ) && do { 
			next unless $add->{subs};

				my $h = { 
						'filename'    => $file,
						'line_number' => $node->line_number,
						######################
						'subname_full'   => $ns.'::'.$node->name,
						'subname_short'  => $node->name,
						'namespace'   => $ns,
						'type'   	  => 'sub',
				};

				$self->dbh_insert_hash({ h => $h });

		};
		$node->isa( 'PPI::Statement::Variable' ) && do { 
			next unless $add->{vars};

			my $type = $node->type;
			next unless $type eq 'our';

			my @a = ($ns,$file,$type);

			$self->process_var($node,@a);
		};
		$node->isa( 'PPI::Statement::Package' ) && do { 
			$ns = $node->namespace; 

			next unless $add->{packs};

			my $h = { 
						'filename'    => $file,
						'line_number' => $node->line_number,
						######################
						'namespace'   => $ns,
						'type'   	  => 'package',
			};

			$self->dbh_insert_hash({ h => $h });
		};
	}

	return $self;
}

sub dbh_insert_hash {
	my ($self,$ref)=@_;

	my $h = $ref->{h} || {};
	unless (keys %$h) {
		return $self;
	}

	my $ph = join ',' => map { '?' } keys %$h;
	my @f = keys %$h;
	my @v = map { $h->{$_} } @f ;
	my $e = q{`};
	my $f = join ',' => map { $e . $_ . $e } @f;
	my $q = qq| 
		insert into `tags` ($f) values ($ph) 
	|;
	eval {$dbh->do($q,undef,@v); };
	if ($@) {
		$self->warn($@,$q,$dbh->errstr);
	}

	return $self;
}

sub write_tags {
	my ($self,$ref)=@_;

	my $tagfile = $ref->{tagfile} || $self->{tagfile} || '';
	unless ($tagfile) {
		return $self;
	}

	$self->log('write_tags: ' . $tagfile);

	my $queries = [ 
		{ 	q => qq{ 
				SELECT 
					`subname_full`,`filename`,`line_number`
				FROM
					`tags`
				WHERE
					`type` = ?
			},
			params => [qw(sub)],
		},
		{ 	q => qq{ 
				SELECT 
					`subname_short`,`filename`,`line_number`
				FROM
					`tags`
				WHERE
					`type` = ?
			},
			params => [qw(sub)],
		},
		{ 	q => qq{ 
				SELECT 
					`namespace`,`filename`,`line_number`
				FROM
					`tags`
				WHERE
					`type` = ?
			},
			params => [qw(package)],
		},
		{ 	q => qq{ 
				SELECT 
					`var_full`,`filename`,`line_number`
				FROM
					`tags`
				WHERE
					`type` = ?
			},
			params => [qw( var_our )],
		},
		{ 	q => qq{ 
				SELECT 
					`var_short`,`filename`,`line_number`
				FROM
					`tags`
				WHERE
					`type` = ?
			},
			params => [qw( var_our )],
		},
	];

	$self->tags_add({ queries => $queries });

	my $q = q{
		SELECT 
			`tag`,`file`,`address`
		FROM 
			`tags_write`
		ORDER BY 
			`tag`
		ASC
	};
	my $sth = $dbh->prepare($q);
	eval { $sth->execute(); };

	if ($@) {
		$self->warn($@,$q,$dbh->errstr);
		return $self;
	}

	my $fetch='fetchrow_arrayref';
	my @lines;
	while(my $row=$sth->$fetch()){
		push @lines, join("\t",@$row);
	}

	append_file($tagfile,join("\n",@lines) . "\n");

	return $self;
}

sub tagfile_rm {
	my ($self,$ref)=@_;

	my $tagfile = $ref->{tagfile} || $self->{tagfile} || '';
	rmtree $tagfile if -e $tagfile;

	return $self;
}

=head2 tags_add

=head3 Usage

	# single query:
	$pf->tags_add({ 
		tagfile => $tagfile,
		query => q{...},
		params => [...],
	});

	# iterate over queries:
	my $queries = [ { q => q{...}, params => [...] }, { ... }, ];

	$pf->tags_add({ 
		tagfile => $tagfile,
		queries => $queries,
	});

=cut

sub tags_add {
	my ($self,$ref)=@_;

	my ($query,$queries,$params)=@{$ref}{qw( query queries params )};

	my $tagfile = $ref->{tagfile} || $self->{tagfile} || '';

	$queries = [] if ($query);
	if ($queries && @$queries) {
		foreach (@$queries) {
			$self->tags_add({ 
				query  => $_->{q},
				params => $_->{params},
			});
		}
		return $self;
	}

	$self->log('tags_add: ' . Dumper($ref));

	my $sth = $dbh->prepare($query);
	eval { $sth->execute(@$params); };

	if ($@) {
		$self->warn($@,$query,Dumper($params),$dbh->errstr);
		return $self;
	}

	my $fetch='fetchrow_arrayref';
	while(my $row=$sth->$fetch()){
		my @v = @$row;

		my $q = q{
			INSERT INTO 
				`tags_write` (`tag`,`file`,`address`)
			VALUES (?,?,?)
		};
		$dbh->do($q,undef,@v);
	}

	return $self;
}

1;
 

