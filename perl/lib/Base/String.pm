
package Base::String;

use warnings;
use strict;

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
      str_split_trim
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub str_split {
	my ($text) = @_;

	my @a = map { 
		s/^\t*//g; 
		s/^\s*//g; 
		$_ 
	} split "\n" => $text;

	return @a;
}

sub str_split_trim {
	my ($text) = @_;

	my @a = map { 
		s/^\t*//g; 
		s/^\s*//g; 
		s/\s*$//g; 
		length > 0 ? $_ : ()
	} split "\n" => $text;

	return @a;
}

1;
 
