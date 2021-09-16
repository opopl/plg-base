
package Base::Opt;

use strict;
use warnings;

sub _opt_ {
    my ($self,$ref,$opt,$default) = @_;

    my $value = $ref->{$opt} // $self->{$opt} // $default;
    return $value;
}

sub _opt_argv_ {
    my ($self,$opt,$default) = @_;

    return $self->{opt}->{$opt} // $default;

}

1;
 

