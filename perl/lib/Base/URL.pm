package Base::URL;

use strict;
use warnings;

use Path::Tiny;

use URL::Normalize;
use URI::Simple;

use URI;
use URI::file;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $WARN;

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
	uri_decompose
	uri_file
	uri_file_string

	url_level
	url_normalize
	url_parent
	url_relative
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

$VERSION   = '0.01';
@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub url_parent {
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
	my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };
	
	my ($uri, $proto, $host, $path, $url_norm);

	$uri = URI->new($url);
	$url_norm = $url;
	
	eval { $proto = $uri->scheme; };
	$proto ||= 'http';

	#------------- host -----------
	eval { $host  = $uri->host; };
	if ($@) {
		my @w; push @w,
			'fail: $uri->host',
			'url: ' . $url,
			$@;
		#$warn->(@w);
	}

	if ($host) {
		$host =~ s/[\/]+/\//g;
	}
	#------------------------------

	$path  = $uri->path;
	if ($path) {
		$path =~ s/[\/]+/\//g;
	}
	
	unless ($host) {
		$path =~ s/^\///g;
		#$url_norm = ($proto) ? $proto . '://' : '';
		$url_norm = $path;
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

sub uri_file_string {
	my $url = uri_file(@_)->as_string;
	$url;
}

sub uri_file {
	my ($file) = @_;

	my $os = $^O eq 'MSWin32' ? 'win32' : '';
	my $uri = URI::file->new($file, $os);

	$uri;
}

sub url_relative {
	my $struct = uri_decompose(@_);

	my $r = {
		path     => $struct->{path_base},
		basename => $struct->{path_base_basename},
		dirname  => $struct->{path_base_parent},
	};

	return $r;

}

sub uri_decompose {
	my ($url,$base_url) = @_;

	$url      = url_normalize($url);
	$base_url = url_normalize($base_url);

	#print $url . "\n";
	#print $base_url . "\n";

	my $uri  = URI::Simple->new($url);

	my @v = qw( host path protocol directory file source );
	my $struct;

	my $path_base = $url;
	$path_base =~ s/$base_url[\/]+//g;

	foreach my $v (@v) {
		my $val = ($uri->can($v)) ? $uri->$v : '';
		$struct->{$v}=$val;
	}

	$struct->{url}  = $url;
	$struct->{root} = join('/' , @{$struct}{qw(host directory )} );
	$struct->{path_base} = $path_base;

	my ($pt_base,$par);

	if ($path_base) {
		$pt_base = path($path_base);

		$par = $pt_base->parent->stringify;
		$struct->{path_base_parent} = $par;
		$struct->{path_base_basename} = $pt_base->basename();
	}


	return ($uri,$struct);
}

sub url_level {
	my ($ref) = @_;

	my $url      = $ref->{url};
	my $base_url = $ref->{base_url};

	( $url, $base_url ) = map { url_normalize($_) } @{$ref}{qw( url base_url )};

	$url =~ s/$base_url//g;

	my @rel = grep { !/^$/ } split(/\//, $url);
	my $lev = scalar @rel || 1;
	$lev--;
	return ($lev,$url);


}

1;
 

