package Base::PerlFile;

use strict;
use warnings;

use PPI;
use File::Find qw(find);
use DBI;

our $dbh = DBI->connect("dbi:SQLite:dbname=:memory:","","");
my @q;
push @q,
	qq{
		create table `tags` (
			filename varchar(1024),
			namespace varchar(1024),
			subname_short varchar(1024),
			subname_full varchar(1024),
			line_number varchar(1024)
		)
	},
	;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={
		exts => [qw(pl pm t)],
	};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

		
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

	my $file = $ref->{file};
	unless (-f $file) {
		return $self;
	}

 	my $DOC = PPI::Document->new($file);
	$DOC->index_locations;

	my $f = sub { $_[1]->isa( 'PPI::Statement::Sub' ) || $_[1]->isa( 'PPI::Statement::Package' ) };
	my @packs_and_subs = @{ $DOC->find( $f ) };

	my $ns;

	my @subs;
	for my $node (@packs_and_subs){
		$node->isa( 'PPI::Statement::Sub' ) && do { 
				push @subs, { 
						'subname_full'   => $ns.'::'.$node->name,
						'subname_short'  => $node->name,
						'line_number' => $node->line_number,
						'filename'    => $file,
						'namespace'   => $ns,
				};
		};
		$node->isa( 'PPI::Statement::Package' ) && do { $ns = $node->namespace; };
	}

	my @lines_tags;
	foreach my $sub (@subs) {
		my @ta = @{$sub}{ qw(full_name file line_number ) };
		my $t = join("\t",@ta);
		push @lines_tags, $t;
	}

	$self->{subnames} = [ map { $_->{full_name} } @subs ];
	$self->{lines_tags} = [@lines_tags];

	$self;
}

1;
 

