
package Plg::Base::Dialog;

use strict;
use warnings;

use File::Spec::Functions qw(catfile);
use Tk;

use FindBin qw( $Bin $Script );
use File::Basename qw(basename);


sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self = shift;

	my $script_name = basename($Script);
	$script_name =~ s/\.(\w+)$//g;

	my $h = { 
		root_dir    => $Bin,
		script_name => $script_name,
	};
		
	my @k = keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	return $self;
}

sub run {
	my $self = shift;

	my $data = catfile( $self->{root_dir}, $self->{script_name} . '.data' );

	return $self;
}

1;
 

