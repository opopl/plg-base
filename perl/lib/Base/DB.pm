
package Base::DB;

use strict;
use warnings;

our $DBH;

use warnings;
use strict;

use Exporter ();

###export_vars_scalar
my @ex_vars_scalar=qw(
	$DBH
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw();

my %EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
	dbh_insert_hash
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

our @EXPORT  = qw( );

our $VERSION = '0.01';

sub dbh_insert_hash {
	my ($ref)=@_;

	my $dbh = $ref->{dbh} || $DBH;

	my $h = $ref->{h} || {};
	my $t = $ref->{t} || '';

	unless (keys %$h) {
		return;
	}

	my $ph = join ',' => map { '?' } keys %$h;
	my @f = keys %$h;
	my @v = map { $h->{$_} } @f ;
	my $e = q{`};
	my $f = join ',' => map { $e . $_ . $e } @f;
	my $q = qq| 
		insert into `$t` ($f) values ($ph) 
	|;
	eval {$dbh->do($q,undef,@v); };
	if ($@) {
		#$warn($@,$q,$dbh->errstr);
	}

}

1;
 

