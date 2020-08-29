
package Base::RE::TeX;

use strict;
use warnings;

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my $self = shift;

    my @n_sec = qw(part chapter section subsection subsubsection paragraph);
    my $n_sec = join("|",@n_sec);

    my $h = {
        sec => qr{^\\(?<secname>$n_sec)\{(?<sectitle>(.*))\}\s*$}
    };
        
    my @k = keys %$h;

    for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

    return $self;
}

1;
 


1;
 

