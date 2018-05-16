package Base::PerlFile;

use strict;
use warnings;
use PPI;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub ppi_list_subs {
	my ($self,$ref)=@_;
	my $file = $ref->{file};

 	my $DOC = PPI::Document->new($file);
	$DOC->index_locations;

	my $f = sub { $_[1]->isa( 'PPI::Statement::Sub' ) || $_[1]->isa( 'PPI::Statement::Package' ) };
	my @packs_and_subs = @{ $DOC->find( $f ) };

	my $ns;

	my @subs;
	for my $node (@packs_and_subs){
		$node->isa( 'PPI::Statement::Sub' ) && do { 
				push @subs, { 
						'full_name'   => $ns.'::'.$node->name,
						'name'        => $node->name,
						'line_number' => $node->line_number,
						'file'        => $file,
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

}

1;
 

