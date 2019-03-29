package Base::String;

use strict;
use warnings;

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
		str_split
	)],
	'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub str_split {
	my ($str,$ref) = @_;

	return () unless $str;

	my @res;
	if (ref $str eq "ARRAY"){
		foreach my $s (@$str) {
			push @res, str_split($s);
		}
		return @res;
	}elsif( not ( ref $str eq "" ) ){
		return ();
	}

	$ref ||= {};

	my $c   = $ref->{comment_start}  || '#';
	my $sep = $ref->{sep}  || "\n";

	@res = 
		map { s/^\s*//g; $_ } 
		grep { !/^\s*$/ && !/^\s*$c/ } 
		split( $sep => $str );

	return @res;
}

1;
 

