package Base::Data;

use utf8;

use strict;
use warnings;

binmode STDOUT,':encoding(utf8)';

use Deep::Hash::Utils qw(
    deepvalue
);
use Base::String qw(
    str_split
    str_split_sn
);

use Exporter ();
use base qw(Exporter);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA     = qw(Exporter);
@EXPORT  = qw( );
$VERSION = '0.01';

###export_vars_scalar
my @ex_vars_scalar=qw(
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [qw(
        d_str_split
        d_str_split_sn
        d_path
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub d_path {
    my ($data, $path, $default) = @_;

    my @path; 
    unless (ref $path) {
        push @path, split(' ',$path);
    }elsif(ref $path eq 'ARRAY'){
        @path = @$path;
    }

    my $val = deepvalue($data,@path) // $default;
    return $val;
}

sub d_str_split {
    my ($data, $path, $ref) = @_;
    $ref ||= {};

    my $val = d_path($data,$path,'');
    my @s = str_split($val,$ref);
    return @s;
}

sub d_str_split_sn {
    my ($data, $path) = @_;

    my $val = d_path($data,$path,'');
    my @s;
    unless (ref $val) {
        push @s, str_split_sn($val);
    }elsif(ref $val eq 'ARRAY'){
        foreach my $x (@$val) {
            push @s, str_split_sn($x);
        }
    }
    return @s;
}

1;
 

