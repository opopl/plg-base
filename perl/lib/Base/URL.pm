package Base::URL;

use strict;
use warnings;

use Path::Tiny;
use URL::Normalize;
use URI;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

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
	url_base
	url_normalize
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

$VERSION   = '0.01';
@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub url_base {
	my ($url) = @_;
}


sub url_normalize {
	my ($url,$ref) = @_;

	$ref ||= {};

	my $uri = URI->new($url);

	my $proto = $uri->scheme;
	my $host  = $uri->host;
	my $path  = $uri->path;

	$path =~ s/[\/]+/\//g;
	$host =~ s/[\/]+/\//g;

	my $url_norm = $url;
	unless ($host) {
		$path =~ s/^\///g;
		$url_norm = $proto . '://' . $path;
	}

	my $norm = URL::Normalize->new($url_norm);
	$norm->remove_duplicate_slashes;
	$norm->remove_dot_segments;

	foreach my $x (qw(remove_fragments)) {
		if ($ref->{$x}) {
			$norm->$x;
		}
	}
	$url_norm = $norm->url;

	return $url_norm;
}

1;
 

