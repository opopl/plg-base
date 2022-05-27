
package Base::Git;

use strict;
use warnings;

use POSIX qw(strftime);
use Carp qw(carp);

use Capture::Tiny qw(capture);
use File::Path qw(rmtree);
use File::Copy qw(move);

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper qw(Dumper);
use File::Basename qw(basename dirname);
use Digest::MD5;

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

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
        git_add
        git_rm
        git_mv
        git_has
    )],
    'vars'  => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

our @EXPORT  = qw( );

our $VERSION = '0.01';

sub git_rm {
    my ($path) = @_;

    return unless git_has($path);

    my $cmd = 'git';
    my @args;
    push @args, 'rm', $path;

    my ($stdout, $stderr, $exit) = capture {
       system( $cmd, @args );
    };

    $stdout && ($exit == 0) ? 1 : 0;
}

sub git_add {
    my ($path) = @_;

    my $cmd = 'git';
    my @args;
    push @args, 'add', $path;

    return if git_has($path);

    my ($stdout, $stderr, $exit) = capture {
       system( $cmd, @args );
    };

    !$stdout && ($exit == 0) ? 1 : 0;
}

sub git_mv {
    my ($old, $new) = @_;

    my $cmd = 'git';
    my @args;
    push @args, 'mv', $old, $new;

    return unless git_has($old);
    return if git_has($new);

    my ($stdout, $stderr, $exit) = capture {
       system( $cmd, @args );
    };

    !$stdout && ($exit == 0) ? 1 : 0;
}


sub git_has {
    my ($path) = @_;

    my $cmd = 'git';
    my @args;
    push @args, 'ls', $path;

    my ($stdout, $stderr, $exit) = capture {
       system( $cmd, @args );
    };

    $stdout && ($exit == 0) ? 1 : 0;
}


1;


