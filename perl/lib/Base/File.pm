package Base::File;

use strict;
use warnings;

use File::Basename qw(basename);

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
        file_tail
        win2unix
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub win2unix {
    my ($file) = @_;

    $file =~ s{\\}{\/}g;

    return $file;
}

sub file_tail {
    my ($file) = @_;
    
    my $bname  = basename($file);
    my ($tail) = ($bname =~ /^(.*)\.(\w+)$/);

    return $tail;
}

1;
 

