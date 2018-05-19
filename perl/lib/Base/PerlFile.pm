package Base::PerlFile;

use strict;
use warnings;

use PPI;
use File::Find qw(find);
use DBI;

our $dbh;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init_db {
	my $self=shift;

	$dbh = DBI->connect("dbi:SQLite:dbname=:memory:","","");
	my @q;
	push @q,
		qq{
			create table if not exists `tags` (
				`id` int auto_increment,
				`filename` varchar(1024),
				`namespace` varchar(1024),
				`subname_short` varchar(1024),
				`subname_full` varchar(1024),
				`line_number` varchar(1024),
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
		chdir $dir;

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
		},'.'
		);
	}

	$self->{files_source}=[@files];

	$self;
}

sub ppi_list_subs {
	my ($self,$ref)=@_;

	my $files = $ref->{files} || $self->{files_source} || [];

	if (@$files) {
		foreach my $file (@$files) {
			$self->ppi_list_subs({ file => $file });
		}
	}

	my $file = $ref->{file};
	unless ($file && -f $file) { return $self; }

 	my $DOC = PPI::Document->new($file);
	$DOC->index_locations;

	my $f = sub { $_[1]->isa( 'PPI::Statement::Sub' ) || $_[1]->isa( 'PPI::Statement::Package' ) };
	my @packs_and_subs = @{ $DOC->find( $f ) };

	my $ns;

	my @subs;
	for my $node (@packs_and_subs){
		$node->isa( 'PPI::Statement::Sub' ) && do { 
				my $h = { 
						'subname_full'   => $ns.'::'.$node->name,
						'subname_short'  => $node->name,
						'line_number' => $node->line_number,
						'filename'    => $file,
						'namespace'   => $ns,
				};

				push @subs, $h;
				my $ph = join ',' => map { '?' } keys %$h;
				my @f = keys %$h;
				my @v = map { $h->{$_} } @f ;
				my $e = q{`};
				my $f = join ',' => map { $e . $_ . $e } @f;
				my $q = qq| 
					insert into `tags` ($f) values ($ph) 
				|;
				$dbh->do($q,undef,@v);
		};
		$node->isa( 'PPI::Statement::Package' ) && do { $ns = $node->namespace; };
	}

	$self;
}

1;
 

