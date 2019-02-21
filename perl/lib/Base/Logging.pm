
package Base::Logging;

use strict;
use warnings;

sub warn {
	my ($self, @args) = @_;

	my $sub = $self->{sub_warn} || $self->{sub_log} || sub { warn $_ for(@_) };
	$sub && $sub->(@args);

	return $self;
}

sub log {
	my ($self, @args) = @_;

	my $sub = $self->{sub_log} || sub { print $_ . "\n" for(@_); };
	$sub && $sub->(@args);

	return $self;
}

1;
 

