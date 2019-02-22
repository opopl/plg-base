package Base::PerlFile;

=head1 NAME

Base::PerlFile - module for processing perl module (*.pm), script (*.pl) files

=cut

use strict;
use warnings;

use PPI;

use File::Find qw( find );
use File::Slurp qw( write_file append_file );
use File::Path qw(rmtree);

use Data::Dumper;
use List::MoreUtils qw(uniq);

use DBI;
use File::stat;

use Base::DB qw(
	dbh_insert_hash
	dbh_select
);
use base qw(Base::Logging);

use vars qw($dbh);

=head1 METHODS 

=cut

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

	my $rows = dbh_select({ 
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
	return $subnames;
}

sub namespaces {
	my ($self, $ref)=@_;
	
	# matching pattern
	my $pat = $ref->{pat} || '';

	my $rows = dbh_select({ 
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

	$dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","",$o);

	$Base::DB::DBH = $dbh;

	my @q;
	my @drop;

	push @drop,
		qq{ DROP TABLE IF EXISTS `files` } ,
		#qq{ DROP TABLE IF EXISTS `tags` } ,
		#qq{ DROP TABLE IF EXISTS `tags_write` } 
	;
	push @q, @drop;

###t_files
	push @q,
		qq{
			CREATE TABLE IF NOT EXISTS `files` (
				`id` INT AUTO_INCREMENT,
				`file` VARCHAR(1024) NOT NULL UNIQUE,
				`file_mtime` VARCHAR(1024) NOT NULL,
				`dir` VARCHAR(1024) NOT NULL,
				PRIMARY KEY(`id`)
			);
		},
###t_tags
		qq{
			create table if not exists `tags` (
				`id` int auto_increment,
				`filename` varchar(1024),
				`file_mtime` varchar(1024),
				`dir` varchar(1024),
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
				`include_module` varchar(1024),
				`include_arguments` varchar(1024),
				`content` text,
				primary key(`id`)
			);
		},
###t_tags_write
		qq{
			create table if not exists `tags_write` (
				`id` int auto_increment,
				`tag` varchar(1024),
				`file` varchar(1024),
				`address` varchar(1024),
				primary key(`id`)
			);
		},
		;
	
	foreach my $q (@q) {
		eval { $dbh->do($q); };
		if ($@) { 
			my @m; 
			push @m,
				'FAIL: dbh->do(...)',
				'q:',$q,
				'dbh->errstr:',$dbh->errstr; 
			die join "\n" => @m;
		}
	}

	return $self;
}

sub init {
	my $self=shift;

	my $h = {
		exts => [qw(pl pm t)],
		add  => [qw(
				include
				packages 
				subs 
				vars 
		)],
	};
		
	my @k = keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self->init_db;

	return $self;
		
}

sub load_files_source {
	my($self, $ref) = @_;

	my $dirs = $ref->{dirs} || $self->{dirs} || [];
	my $exts = $ref->{exts} || $self->{exts} || [];

	@$dirs = uniq(@$dirs);
	
	foreach my $dir (@$dirs) {
		next unless -d $dir;

		find({ 
			preprocess => sub { @_ },
			wanted => sub { 
				return unless -f;
				foreach my $ext (@$exts) {
					if (/\.$ext$/) {
						my ($file, $file_mtime);
						
						$file = $File::Find::name;

						my ($st, $file_mtime);
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
						
						last;
					}
				}
			} 
		},$dir
		);
	}

	$self;
}

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
        # список или выражение - ищем имена рекурсивно:
        $self->process_var( $token, @a ), next if $token->class eq 'PPI::Structure::List';
        $self->process_var( $token, @a ), next if $token->class eq 'PPI::Statement::Expression';
          
		if ( $token->class eq 'PPI::Token::Symbol'){
			my $var = $token->content;
			my $var_full = $ns . '::' . $var;

			my $sign = $token->symbol_type;
			my $varname = $var;

			$var_full = $sign  . $ns . '::' . $varname;

			my $h = {
				'filename'    => $file,
				'file_mtime'  => $file_mtime,
				'line_number' => $node->line_number,
				'var_type'	  => $type,
				'var_short'	  => $var,
				'var_full'	  => $var_full,
				#'var_decl'	  => $node->content,
				'var_parent_class'	  => $node->parent->class,
				'var_parent_lineno'	  => $node->parent->line_number,
				'namespace'   => $ns,
				'type'   	  => 'var_'.( $type || 'undef' ),
			};
			#$self->log(Dumper($h));
	
			dbh_insert_hash({ h => $h, t => 'tags' });
		}

    }
	$self;
}

sub ppi_get_sub_block {
	my ($self,$ref)=@_;

	my $block;
	my $sub_full = $ref->{sub_full};


	return $block;
}

sub files_source {
	my ($self)=@_;

	my $rows = dbh_select({ 
		f => [qw(file file_mtime)], 
		t => 'files', 
	});
	return $rows;
}

sub ppi_process {
	my ($self,$ref)=@_;

	my $files = $ref->{files} || $self->files_source || [];

	my ($file,$file_mtime) = @{$ref}{qw(file file_mtime)};
	$files = [] if $file;

	if (@$files) {
		foreach my $f (@$files) {
			$self->ppi_process($f);
		}
	}


	unless ($file && -f $file) { return $self; }

	my $rows = dbh_select({
		s    => 'SELECT DISTINCT',
		f    => [qw(file_mtime)],
		t    => 'tags',
		cond => qq{ where filename = ? },
		p    => [$file],
	});
	my ($mtime_db) = map { $_->{file_mtime} } @$rows;
	# file is modified compared to its data stored in database
	if (defined $mtime_db && ($file_mtime == $mtime_db)) {
		return $self;
	}

 	my $DOC; 
	eval { $DOC = PPI::Document->new($file); };
	if ($@) { $self->warn($@); return $self; }

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
						'filename'    => $file,
						'file_mtime'  => $file_mtime,
						'line_number' => $node->line_number,
						######################
						'subname_full'   => $ns.'::'.$node->name,
						'subname_short'  => $node->name,
						'namespace'   => $ns,
						'type'   	  => 'sub',
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
			#$self->log(Dumper($vars));

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
					'namespace'   => $ns,
					'type'   	  => 'include_'.$node->type,
					'include_module'   	  => $module ,
					'include_arguments'   => $a,
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
						$self->warn('PPI::Statement::Include: $sign zero!');
					}

					my $h = { 
							'filename'    => $file,
							'file_mtime'  => $file_mtime,
							'line_number' => $node->line_number,
							######################
							'namespace'   => $ns,
							'type'   	  => 'var_our',
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
						'type'   	  => 'package',
			};

			dbh_insert_hash({ h => $h, t => 'tags' });
		};
	}

	return $self;
}

=head2 write_tags

=head3 Usage 

	my $ref={
		# full path to the tagfile which will be written
		tagfile => $tagfile,
	};

	# $pf is a Base::PerlFile instance
	$pf->write_tags($ref);

=cut

sub write_tags {
	my ($self,$ref)=@_;

	my $tagfile = $ref->{tagfile} || $self->{tagfile} || '';
	unless ($tagfile) {
		return $self;
	}

	$self->log('write_tags: ' . $tagfile);

	my $add = $ref->{add} || $self->{add} || [];

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

	for(@$add){
   #     /^include$/ && do { 
			#push @$queries,
				#{ 	q => qq{ 
						#SELECT 
							#`var_full`,`filename`,`line_number`
						#FROM
							#`tags`
						#WHERE
								#`type` = ? 
							#AND 
								#`include_module` = ? 
					#},
					#params => [qw( 
						#include_use 
						#vars
					#)],
				#};
			#next;
		#};
	}

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
		#push @lines, join("\t",map { defined ($_) ? $_ : 'undef' }@$row);
		push @lines, join("\t",@$row);
	}

	append_file($tagfile,join("\n",@lines) . "\n");

	return $self;
}

sub generate_from_source {
	my ($self)=@_;

	$self
		->load_files_source
		->ppi_process
		->tagfile_rm
		->write_tags
		;
	
	return $self;
}

sub tagfile_rm {
	my ($self,$ref) = @_;

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
 

