

package Base::Enc;

use strict;
use warnings;

use Encode qw(decode encode);

use base 'Exporter';

our @EXPORT_OK = qw(
    UNC
    enc
    enc_in
    enc_out
    unc_decode
    unc_encode
);

use constant UNC => 'UTF-8';

sub enc_in {
    my ($enc) = @_;
    $enc ||= UNC;

    sprintf('<:encoding(%s)',$enc);
}

sub enc {
    my ($enc) = @_;
    $enc ||= UNC;

    sprintf(':encoding(%s)',$enc);
}

sub enc_out {
    my ($enc) = @_;
    $enc ||= UNC;

    sprintf('>:encoding(%s)',$enc);
}

sub unc_decode {
    my ($t, $enc) = @_;

    $enc ||= UNC;
    my $s = Encode::decode($enc,$t);

    return $s;
}

sub unc_encode {
    my ($t, $enc) = @_;

    $enc ||= UNC;
    my $s = Encode::encode($enc,$t);

    return $s;
}

1;
 

