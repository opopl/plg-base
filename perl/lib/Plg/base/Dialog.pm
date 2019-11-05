
package Plg::Base::Dialog;

use strict;
use warnings;

use File::Spec::Functions qw(catfile);
use Tk;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub run {
	my $self = shift;

	my $data = catfile($self->{root_dir}, $self->{script_name} . '.data');

	return $self;
}

1;
 

