package Base::URL;

use strict;
use warnings;

use Path::Tiny;

use URL::Normalize;
use URI;
use URI::Simple;

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
	uri_decompose
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

$VERSION   = '0.01';
@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub url_base {
	my ($url) = @_;

	$url = url_normalize($url);

	my $u  = URI->new($url);
	my $pt = path($u->path);

	my $parent = $pt->parent->stringify;

	$u->path($parent);

	return $u->as_string;
}


sub url_normalize {
	my ($url,$ref) = @_;

	$ref ||= { };

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

	my @x = qw(
		remove_fragments
		remove_query_parameters
	);
	foreach my $x (@x) {
		next unless $ref->{$x};
			
		$norm->$x;
	}
	$url_norm = $norm->url;

	return $url_norm;
}

sub uri_decompose {
	my ($url,$base_url) = @_;

	my $uri  = URI::Simple->new($url);

	my @v = qw( host path protocol directory file source );
	my $struct;

	my $path_base = $url;
	$path_base =~ s/$base_url//g;

	foreach my $v (@v) {
		my $val = ($uri->can($v)) ? $uri->$v : '';
		$struct->{$v}=$val;
	}

	$struct->{url}  = $url;
	$struct->{root} = join('/' , @{$struct}{qw(host directory )} );
	$struct->{path_base} = $path_base;

	return ($uri,$struct);
}

1;
 

