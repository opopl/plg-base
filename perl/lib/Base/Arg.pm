
package Base::Arg;

use strict;
use warnings;

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
		arg_to_list
		hash_update
	)],
	'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub arg_to_list {
	my ($arg) = @_;

	$arg ||= [];

	my @list;
	if (ref $arg eq "ARRAY"){
		@list = @$arg;
		
	}elsif(ref $arg eq ""){
		@list = str_split($arg);
		
	}
	return wantarray ? @list : \@list ;
}

sub hash_update {
	my ($hash,$update) = @_;

	while(my($k,$v) = each %{$update}){
		$hash->{$k} = $v;
	}
}

1;
 

