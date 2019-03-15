package Base::Util;

use strict;
use warnings;


use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

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
	replace_undefs
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

our @EXPORT  = qw( );

our $VERSION = '0.01';

sub replace_undefs {
	my ($struct) = @_;

	if (ref $struct eq ""){
		$struct = "" unless defined $struct;

	}elsif (ref $struct eq "SCALAR"){
		$$struct = "" unless defined $$struct;

	}elsif (ref $struct eq "ARRAY"){
		foreach my $x (@$struct) {
			$x = replace_undefs($x);
		}

	}elsif(ref $struct eq "HASH"){
		foreach my $x (keys %$struct) {
			my $v = $struct->{$x};
			$struct->{$x} = replace_undefs($v);
		}
	}

	return $struct;
}

1;
 

