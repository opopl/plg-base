
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

use Base::String qw(str_split);

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

=head2 hash_update

=head3 Purpose

=head3 Usage

	use Base::Arg qw(hash_update);

	my ($hash, $update);

	my $opts = {
		# OPTIONAL: 
		# 	default: 0
		keep_already_defined => 1,

		# OPTIONAL: 
		# 	default: 0
		update_from_defined => 1,
	};
	# update $hash with the contents of 
	# 	$update;
	# 	$opts defined additional update options
	hash_update($hash, $update, $opts);

=head3 Examples

=cut	

sub hash_update {
	my ($hash, $update, $opts) = @_;

	$opts ||= {};

	while( my($k, $v) = each %{$update} ){
		# do not update if the corresponding field
		# 	has been already defined before and elsewhere
		if ($opts->{keep_already_defined}) {
			next if defined $hash->{$k};
		}

		# update $hash ONLY if the corresponding value 
		# is defined, i.e. is not undef
		if ($opts->{update_from_defined}) {
			next unless defined $update->{$k};
		}

		$hash->{$k} = $v;
	}
}

1;
 

