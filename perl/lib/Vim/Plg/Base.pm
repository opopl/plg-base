
package Vim::Plg::Base;

=head1 NAME

Vim::Plg::Base

=cut

use strict;
use warnings;

use File::Spec::Functions qw(catfile);
use File::Find qw(find);
use File::Dat::Utils qw(readarr);
use File::Basename qw(basename dirname);

use Data::Dumper;

use Vim::Perl qw(VimMsg);

use DBD::SQLite;
use DBI;

use Base::DB qw(
	dbh_insert_hash
	dbh_select
	dbh_do
);

use base qw( 
	Class::Accessor::Complex 
	Base::Logging
);

use File::Path qw(mkpath);
use File::stat qw(stat);

our @TYPES = qw(list dict listlines );


=head1 SYNOPSIS

	my $plgbase=Vim::Plg::Base->new;

=head1 METHODS

=cut

=head2 init 

=over

=item Usage

=back

=cut

sub init {
	my $self=shift;

	return unless $^O eq 'MSWin32';

	$self
		->init_dirs
		->init_dbfiles
		->init_sqlstm
		->init_vars
		->db_connect
		->db_drop_tables
		->db_create_tables
		->init_dat;

	$self;

}

sub init_vars {
	my $self=shift;

	my $dbname = 'main';
	my $dbid   = $dbname;

	my $dbfile = $self->dbfiles($dbid);

	$self->dbid($dbid);

	my $h={
		withvim      => $self->_withvim(),
		dbname       => $dbname,
		dbid         => $dbid,
		dbfile       => $dbfile,
		dattypes     => [@TYPES],
		dbopts       => {
			tb_reset => {},
			tb_order => [qw(log plugins datfiles files exefiles)],
		},

	};

	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self;
}

sub init_sqlstm {
	my ($self) = @_;

	my $h = {
		sqlstm => {
			create_table_log => qq{
				CREATE TABLE IF NOT EXISTS log (
					msg TEXT,
					time INTEGER,
					loglevel TEXT
				);
			},
			create_table_plugins => qq{
				create table if not exists plugins (
					id integer primary key asc,
					plugin varchar(255) unique
				);
			},
			create_table_datfiles => qq{
				create table if not exists datfiles (
					id integer primary key asc,
					key varchar(255) unique,
					plugin varchar(255),
					type varchar(255),
					datfile varchar(255)
				);
			},
			create_table_exefiles => qq{
				create table if not exists exefiles (
					id integer primary key asc,
					fileid varchar(255) unique,
					file varchar(255),
					pc varchar(255)
				);
			},
			create_table_files => qq{
				create table if not exists files (
					id integer primary key asc,
					fileid varchar(255) unique,
					type varchar(255),
					file varchar(255)
				);
			},
		},
	};

	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self;
}

sub init_dbfiles {
	my $self=shift;

	my $dbfiles = {
		main       => catfile($self->dirs('appdata'),'main.db'),
		saved_urls => catfile($self->dirs('appdata'),
			qw(saved_urls saved_urls.sqlite )),
	};
	$self->dbfiles($dbfiles);

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
	my ($self, $dbid) = @_;

	my ($dbfile, $dbname);
   
	$dbfile	= $self->dbfile;
	$dbname = $self->dbname;
	
	if ($dbid) {
		$dbfile = $self->dbfiles($dbid) || $dbfile;
		$dbname = basename($dbfile);
		$dbname =~ s/\.(\w+)//g;
	}else{
		$dbid = $self->dbid;
	}

	eval { $self->dbh->disconnect;  };
	#if ($@) { $self->warn('Failure to disconnect db!'); }

	my $dbh;
	
	eval { $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","",""); };
	if ($@) { 
		my $w = 'Failure to connect to database with dbid =' . $dbid .' and dbname =' . $dbname;
		$self->warn($w); return $self; 
	}

	$self->dbfile($dbfile);
	$self->dbname($dbname);
	$self->dbid($dbid);
	$self->dbh($dbh);

	$self;
}

sub update {
	my ($self,%o) = @_;

	foreach my $k (keys %o) {
		$self->{$k} = $o{$k};
	}
	$self;
}

sub reload_from_fs {
	my $self=shift;

	my %o=(
		dbopts       => {
			tb_reset => {plugins => 1, datfiles => 1},
			tb_order => [qw(plugins datfiles)],
		},
	);
	$self
		->update(%o)
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

sub dat_add {
	my $self=shift;

	my $ref=shift;

	my $datfile = $ref->{datfile};
	my $key     = $ref->{key};

	$self->datfiles($key => $datfile );

	$self->db_insert_datfiles($ref);
}

=head2 dat_locate_from_fs 

=head3 Usage

	my $ref={
		type 	=> TYPE (string, one of of: list,dict,listlines - stored in dattypes array),
		plugin 	=> PLUGIN (string ),
		prefix 	=> PREFIX (string ),
	};

	$plgbase->dat_locate_from_fs($ref);

=head3 Purpose

=cut

sub dat_locate_from_fs {
	my $self = shift;
	my $ref  = shift;

	my @dirs   = grep { (-d $_) } @{$ref->{dirs} || []};
	return unless @dirs;

	my $prefix = $ref->{prefix} || '';
	my $type   = $ref->{type} || '';
	my $plugin = $ref->{plugin} || 'base';

	find({ 
		wanted => sub { 
			my $name = $File::Find::name;
			my $dir  = $File::Find::dir;
			my $pat  = qr/\.i\.dat$/;

			/$pat/ && do {
					s/$pat//g;
					my $k=$prefix . $_;
					$self->dat_add({ 
							key     => $k,
							type    => $type,
							plugin  => $plugin,
							datfile => $name,
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

sub get_plugins_from_db {
	my $self=shift;

	#return if $self->done('get_plugins_from_db');

	my @p=$self->db_list_plugins;

	$self->plugins([@p]);

}

sub get_datfiles_from_db {
	my $self=shift;

	my $ref=shift || {};

	my $dbh    = $self->dbh;
	my @fields = qw(key plugin datfile);
	my $f      = join(",",map { '`'.$_.'`'} @fields);

	my $tb = "datfiles";
	my $q  = qq{select $f from `$tb`};

	if (! $self->db_table_exists($tb)) {
		$self->warn('db table is absent:',$tb);
		if ($ref->{reload_from_fs}) {
			$self->reload_from_fs;
		}
		return;
	}

	my $sth;
	eval { $sth    = $dbh->prepare($q); };
	if ($@) { 
		my @m; 
		push @m, 'Errors for $dbh->prepare($q),','$q=',$q,$@,'$dbh->errstr:',$dbh->errstr;
		$self->warn(@m); 
		return;
	}
	unless(defined $sth){
		$self->warn('$sth undefined after $dbh->prepare($q),','$q=',$q); 
		return;
	}

	eval { $sth->execute(); };
	if ($@) { 
		my @m; 
		push @m, 'Errors for $sth->execute(),',$@,'$dbh->errstr:',$dbh->errstr;
		$self->warn(@m); 
		return;
	}


	while (my $row=$sth->fetchrow_hashref()) {
		my ($key,$plugin,$datfile)=@{$row}{@fields};
		$key=join('_',$plugin,$key);

		$self->datfiles($key => $datfile);
	}

}

sub db_tables {
	my $self=shift;

	my $dbname = $self->dbname;
	my $dbh    = $self->dbh;

	my $sub_warn = $self->{sub_warn} || sub {};
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

	my $rows = dbh_select({ 
		dbh  => $dbh,
		warn => $sub_warn,
		q    => $q,
	});

	my @tables = map { $_->{name} }  @$rows;

	#my $pat    = qr/"$dbname"\."(\w+)"/;
    #my @tables = map { /$pat/ ? $1 : () } $dbh->tables;

	wantarray ? @tables : \@tables ;
}

#VimMsg($plgbase->db_table_exists('datfiles'));
#

sub db_table_exists {
	my ($self, $tb) = @_;

	my %tables = map { (defined $_) ? ($_ => 1 ) : () } $self->db_tables;
	my $ex = $tables{$tb} ? 1 : 0;

	return $ex;

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
	$@ && do { $self->warn("File::stat errors for $dbfile: $@"); return; };

	my $size=$st->size;
	return $size;
}



=head2 db_drop_tables 

=head3 Usage

	$plgbase->db_drop_tables({ tb_reset => { ... }});

=head3 Purpose

=cut

sub db_drop_tables {
	my $self = shift;

	my $ref  = shift || {};

	my $dbopts = $ref->{dbopts} || $self->dbopts;

	# which tables to drop 
	my $tb_reset=$ref->{tb_reset} || $dbopts->{tb_reset} || {};

	# order of tables to be dropped
	my $tb_order=$ref->{tb_order} || $dbopts->{tb_order} || [];

	my $dbh=$self->dbh;

	my @s;
	foreach my $tb (@$tb_order) {
		if ($ref->{all} || $tb_reset->{$tb}) {
			push @s, qq{ DROP TABLE IF EXISTS $tb; };
		}
	}

	$self->db_do([@s]);

	$self;
}

sub db_do {
	my $self = shift;

	my $qs  = shift || [];
	my $ref = shift || {};

	my @q   = @$qs;
	my $dbh = $self->dbh;

	foreach my $q (@q) {
		eval { $dbh->do($q) or do { $self->warn($dbh->errstr,$q)}; };
		if ($@) {
			$self->warn('Errors while dbh->do($q)','$q=',$q,$dbh->errstr,$@);
		}
	}

	$self;

}

sub db_create_tables {
	my $self=shift;

	my $dbopts = $self->dbopts;
	my @s;

	my $tb_reset = $dbopts->{tb_reset} || {};
	my $tb_order = $dbopts->{tb_order} || [];

	my $dbh = $self->dbh;

	foreach my $tb (@$tb_order) {
		push @s,$self->sqlstm('create_table_'.$tb);
		
		unless ($self->db_table_exists($tb)) {
			$tb_reset->{$tb}=1;
		}
	}

	$self->db_do([@s]);

	$self;
}

sub db_insert_plugins {
	my $self=shift;
	my @p=@_;

	my $dbh = $self->dbh;

	my $q = q{ INSERT OR IGNORE INTO plugins ( plugin ) VALUES(?) };
	$self->db_prepare();
	my $sth=$self->sth;

	unless ($sth) {
		$self->warn('db_insert_plugins: sth undefined!');
		return $self;
	}
	for(@p){	
		$sth->execute($_);
	}

	$self;
}

sub warn_dbh_undef {
	my $self=shift;

	my $pref=(caller[1])[3];
	$self->warn($pref.': $dbh undefined!'); 
	return $self;
}

sub db_prepare {
	my $self=shift;

	my $q=shift || '';

	$self->{prepared_query}=undef;

	my $dbh = $self->dbh;

	unless (defined $dbh) { return $self->warn_dbh_undef; }

	my $sth=undef;
	eval { $sth = $dbh->prepare($q); };
	$self->sth($sth);

	if ($@) {
		my $s='eval { $sth = $dbh->prepare($q); };';
		my @m;
		push @m,
			'db_prepare: errors while executing:',$s,
			'message thrown:',$@,
			'$dbh->errstr=',$dbh->errstr,
			'query $q=',$q,
		$self->warn(@m);
		return $self;
	}

	defined $sth or do { 
		my @m;
		push @m,
			'db_prepare: $sth undefined!',
			'dbh->errstr=',$dbh->errstr,
			'query $q=',$q;
		$self->warn(@m);
		return $self;
	};

	$self->{prepared_query}=$q;


	$self;

}

sub db_execute {
	my $self=shift;

	my @e=@_;

	my $sth=$self->sth;
	my $dbh=$self->dbh;

	unless (defined $sth) {
		$self->warn('db_execute: $sth undefined!'); 
		return $self;
	}
	unless (defined $dbh) { return $self->warn_dbh_undef; }

	my $q=$self->prepared_query || '';
	unless ($q) {
		$self->warn('db_execute: no query prepared!');
		return $self;
	}

	eval {$sth->execute(@e) or
	   	do {
			$self->warn($dbh->errstr,$q,Dumper(\@e));
			return $self;
		}; 
	};
	if ($@) {
		my @m;
		push @m,
			'db_execute: $sth undefined!',
			'dbh->errstr=',$dbh->errstr;
		$self->warn(@m);
		return $self;
	}

	$self;
	
}

sub db_insert_datfiles {
	my $self = shift;
	my $ref  = shift || {};

	my ($dbh,$sth);
	$dbh=$self->dbh;
	$sth=$self->sth;

	my $q=q{
		INSERT OR IGNORE INTO 
			datfiles(key,type,plugin,datfile) 
		VALUES(?,?,?,?) };
	my @e=@{$ref}{qw(key type plugin datfile)};

	$self->db_prepare($q)->db_execute(@e);

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

	if ($tb_reset->{datfiles}) {
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
	}else{
		$self->get_datfiles_from_db;
	}
	$self;
}

sub init_dat_plugins {
	my $self=shift;

	my @plugins = $self->plugins;
	my @types   = $self->dattypes;

	my $dbopts   = $self->dbopts_ref;
	my $tb_reset = $dbopts->{tb_reset} || {};

	if ($tb_reset->{datfiles}) {
		# find all *.i.dat files for the rest of plugins, except  base plugin
		foreach my $p (@plugins) {
			next if $p eq 'base';

			foreach my $type (@types) {
				my $pdir = catfile($ENV{VIMRUNTIME},qw(plg),$p,qw(data),$type);
				$self->dat_locate_from_fs({ 
					dirs   => [$pdir],
					type   => $type,
					plugin => $p,
					prefix => $p . '_'
				});
			}
		}
	}else{
		$self->get_datfiles_from_db;
	}

}

sub warn {
	my $self = shift;
	my @m    = @_;

	my $sub_warn=$self->{sub_warn} || sub {};

	$sub_warn->(@m);

	$self;

}

sub init_plugins {
	my $self=shift;

	my @types    = $self->dattypes;
	my $dbopts   = $self->dbopts_ref;

	my $tb_reset=$dbopts->{tb_reset} || {};
	my $tb_order=$dbopts->{tb_order} || [];

	if ($tb_reset->{plugins}) {

		my $dat_plg = $self->datfiles('plugins');
		unless ($dat_plg) {
			$self->warn('plugins DAT file NOT defined!!');
		}
		if (-e $dat_plg) {
			my @plugins = readarr($dat_plg);
		
			$self->plugins([@plugins]);
			$self->db_insert_plugins(@plugins);
		}
	}else{
		# 	fill plugins array
		$self->get_plugins_from_db;
	}

	$self;


}

sub init_dat {
	my $self = shift;

	$self
		->init_dat_base
		->init_plugins
		->init_dat_plugins
		;

	$self;

}

BEGIN {
	###__ACCESSORS_SCALAR
	our @scalar_accessors=qw(
		dbh
		sth
		dbfile
		dbname
		dbid
		withvim
		sub_warn
		sub_log
		prepared_query
	);
	
	###__ACCESSORS_HASH
	our @hash_accessors=qw(
		dirs
		dbfiles
		datfiles
		vars
		dbopts
		done
		sqlstm
	);
	
	###__ACCESSORS_ARRAY
	our @array_accessors=qw(
		dattypes
		plugins
	);

	__PACKAGE__
		->mk_scalar_accessors(@scalar_accessors)
		->mk_array_accessors(@array_accessors)
		->mk_hash_accessors(@hash_accessors)
		->mk_new;

}

1;
 

