
package Base::RE::TeX;

use strict;
use warnings;

use Base::Arg qw( hash_update );

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
        sec   => qr{^\\(?<secname>$n_sec)\{(?<sectitle>(.*))\}\s*$},
        label => qr{^\\label\{(?<label>.*)\}\s*$},
    };

    hash_update($self, $h, { keep_already_defined => 1 });

    return $self;
}

1;
 


1;
 

