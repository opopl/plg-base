
package Base::Obj;

use strict;
use warnings;

use Deep::Hash::Utils qw( deepvalue );
use Data::Dumper qw(Dumper);
use Base::String qw(
    str_split
);
use JSON::XS;
use File::Slurp::Unicode;

#my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
#$pretty_printed_unencoded = $coder->encode ($perl_scalar);
#$perl_scalar = $coder->decode ($unicode_json_text);

sub _hash_ {
    my ($self) = @_;

    my %a = map { $_ => $self->{$_} } keys %{$self};

    return \%a;
}

sub _hash_w2file {
    my ($self, $file) = @_;

    my $h = $self->_hash_;
    write_file($file,Dumper($h) . "\n");
}

sub _vals_ {
    my ($self, $path, $sep) = @_;
	$sep ||= '\.';

    my @path_split = map { split($sep => $_) } ( ref $path eq 'ARRAY' ? @$path : ($path));

    my $val = deepvalue($self->_hash_, @path_split);
    return $val;
}

sub _val_ {
    my ($self, @path) = @_;

    @path = map { split(" " => $_) } @path;

    my $val = deepvalue($self->_hash_,@path);
    return $val;
}

sub _val_list_ref_ {
    my ($self,@path) = @_;

    my @res = $self->_val_list_(@path);
    return [ @res ];
}

sub _val_list_ {
    my ($self,@path) = @_;

    my $val = $self->_val_(@path);
    return () unless defined $val;

    my @val;
    unless(ref $val){
        @val = str_split($val);
    }elsif (ref $val eq 'ARRAY') {
        @val = @$val;
    }elsif (ref $val eq 'CODE') {
        my $res = $val->();
        unless (ref $res) {
            @val = str_split($res);
        }elsif (ref $res eq 'ARRAY') {
            @val = @$res;
        }
    }
    return @val;
}



1;
 

