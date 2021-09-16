
package Base::URL;

=head1 NAME

Base::URL -- collection of URL-handling functions.

=head1 METHODS

=cut

use strict;
use warnings;

use Path::Tiny qw(path); 

use URI::Simple;
use Data::Dumper;
use Base::Arg qw(hash_update);

#use Base::URL::Norm;

use String::Util qw(trim);

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
    url_type
    url_cat

    url_remove_query
    url_query
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

$VERSION   = '0.01';
@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

=head2 url_parent

=cut

sub url_parent {
    my ($url) = @_;

    url_normalize(\$url);

    return unless $url;
    
    my $u  = URI->new($url);
    my $pt = eval { path($u->path); }; 
    if ($@) {
        warn $@ . "\n";
        warn $@ . Dumper($url) . "\n";
        warn $@ . Dumper($u) . "\n";
        return;
    }
    
    my $parent = $pt->parent->stringify;
    
    $u->path($parent);
    
    return $u->as_string;
}

sub url_type {
    my ($url) = @_;

    my $type;
    local $_ = $url;
    $_ = trim($_);
    
    $type = 'relative';
    while(1){
        m/^#/ && do { $type = 'id'; last; };
        m|^(\w+)://| && do { $type = 'external'; last; };

        last;
    }
    return $type;
}

sub url_cat {
    my ($base_url, $url) = @_;

    my $t = url_type($url);

    my $jn;

    if ($t eq 'external') {
        $jn = $url;
    }else{
        $jn = join("/",$base_url,$url);
    }
    return $jn;
}

=head2 url_normalize

=head3 Purpose

Convert input URL to some 'normalized' version

=head3 Usage

    $url = url_normalize($url, $ref);

    url_normalize(\$url, $ref);

=head4 Input parameters

=over 4

=item * URL - parameter 1 (required), can be:

=over 4

=item * C<$url> - input URL as a STRING

=item * C<\$url> - input URL as a SCALAR REF

=back 

=item * C<$ref> - parameter 2 (optional) - HASHREF with options 

=back

=head3 C<$ref> contents

Input C<$ref> is HASHREF.

=head4 Protocol

    my $r = { 
        proto => 'https',
    };
    my $url = 'http://www.google.com';

    url_normalize(\$url, $r);

=head4 URL type

URL type, can be: relative, external, id, as returned by
L<url_type()>

    my $r = { 
        type => 'internal',
    };
    my $url = 'http://www.google.com';

    url_normalize(\$url, $r);

=cut


sub url_normalize {
    my ($url, $ref) = @_;

    return '' unless $url;

    if (ref $url eq "SCALAR"){
        my $u = $$url;
        $$url = url_normalize($u,$ref);
        return $$url;
    }
    
    my $defs = { proto => 'http' };
    
    my $o = { keep_already_defined => 1 };
    hash_update($ref, $defs, $o );

    my $type = $ref->{type} || url_type($url);

    my $url_norm = $url;
    
    my $uri = URI->new($url);

    my $proto = eval { $uri->scheme; } || $ref->{proto};

    my $host = eval { $uri->host; } || '';
    $host =~ s/[\/]+/\//g;

    my $fragment = eval { $uri->fragment; } || '';

    my $path  = eval { $uri->path } || ''; 
    $path  =~ s/[\/]+/\//g;
    
    unless ($host) {
        $path =~ s/^\///g;

        # what was identified as a path is actually the host
        if ($type eq 'external') {
            $url_norm = ($proto) ? $proto . '://' . $path . $fragment : '';

        } elsif ($type eq 'relative') {
            $url_norm = $path;
            return $url_norm;

        } elsif ($type eq 'id') {
            return '#' . $fragment;
        }
    }

    $url_norm = $url;

    if ($^O eq 'MSWin32') {
        eval { 
            require Base::URL::Norm;
            my $norm = Base::URL::Norm->new($url_norm);
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
        }
    }

    return $url_norm;
}

sub url_remove_query {
    my ($url) = @_;

    return '' unless $url;

    if (ref $url eq "SCALAR"){
        my $u = $$url;
        $$url = url_remove_query($u);
        return $$url;
    }

    my $u = URI->new($url);
    $u->query_form({});

    $u->as_string;

}

sub url_query {
    my ($url, $q) = @_;

    return '' unless $url;

    if (ref $url eq "SCALAR"){
        my $u = $$url;
        return url_query($$url, $q);
    }

    my $uri = URI->new($url);
    $uri->query($q) if $q;

    $uri->query;
}

=head2 url_file_string

=cut

sub uri_file_string {
    my $url = uri_file(@_)->as_string;
    $url;
}

=head2 url_file

=cut

sub uri_file {
    my ($file) = @_;

    my $os = $^O eq 'MSWin32' ? 'win32' : '';
    my $uri = URI::file->new($file, $os);

    $uri;
}

=head2 url_relative

=head3 Usage

    my $r = url_relative( $url, $base_url );

    # full relative url
    my $path = $r->{path};

    # file portion
    my $bname = $r->{basename};

    # directory portion
    my $dname = $r->{dirname};

=cut

sub url_relative {
    my ($url, $base_url) = @_;

    my $struct = uri_decompose($url, $base_url);

    my $r = {
        path     => $struct->{rear},
        basename => $struct->{rear_basename},
        dirname  => $struct->{rear_parent},
    };

    return $r;

}

=head2 uri_decompose

=head3 Purpose

Given some URL, given as C<$url> e.g.

    my $url = "www.example.com/articles/top/12?a=1&b=2";

and some 'base' URL, given as C<$base_url>, e.g.

    my $base_url = "www.example.com/articles";

obtain path 'tail' with respect to C<$base_url>.

=head3 Usage

    my ($uri, $struct) = uri_decompose($url, $base_url);

=head3 Returns

Pair C<$uri, $struct>, where C<$uri> is C<URI::Simple> instance,
and C<$struct> is a HASHREF with the following keys,
which are of two categories

=over 4

=item (1) Inherited from L<URI::Simple> keys, these are:

    host path protocol directory file source

=item (2) Other keys:

    url, root, rear, rear_parent, rear_basename

=over 4

=item * C<url> 

=item * C<root> 

=item * C<rear> 

=item * C<rear_parent> 

=item * C<rear_basename> 

=back

=back

=cut

sub uri_decompose {
    my ($url, $base_url) = @_;

    url_normalize(\$url);
    url_normalize(\$base_url);

    my $uri  = URI::Simple->new($url);

    my @v = qw( host path protocol directory file source );
    my $struct;

    my $rear = $url;
    $rear =~ s/$base_url[\/]+//g;
    #$rear =~ s/$base_url[\/]*//g;

    foreach my $v (@v) {
        my $val = ($uri->can($v)) ? $uri->$v : '';
        $struct->{$v} = $val;
    }

    hash_update($struct,{
        base_url => $base_url,
        url      => $url,
        root     => join('/' , @{$struct}{qw( host directory )} ),
        rear     => $rear,
    });

    my ($pt_tail,$par);

    if ($rear) {
        $pt_tail = path($rear);

        $par = $pt_tail->parent->stringify;
        $struct->{rear_parent} = $par;
        $struct->{rear_basename} = $pt_tail->basename();
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
 

