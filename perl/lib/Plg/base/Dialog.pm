
package Plg::Base::Dialog;

use strict;
use warnings;

use File::Spec::Functions qw(catfile);

use Tk;

use FindBin qw( $Bin $Script );
use File::Basename qw(basename);
use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);
use Data::Dumper qw(Dumper);

use Getopt::Long qw(GetOptions);
use JSON::XS;

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my $self = shift;

    my $script_name = basename($Script);
    $script_name =~ s/\.(\w+)$//g;

    my $h = { 
        root_dir    => $Bin,
        script_name => $script_name,
        opt_str     => [ 
            'run|r',
        ],
        opt         => {},
    };
    
        
    my @k = keys %$h;

    for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

    return $self;
}

      
sub get_opt {
    my ($self) = @_;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    unless( @ARGV ){ 
        $self->dhelp;
        exit 0;
    }else{
        $self->{cmdline} = join(' ',@ARGV);
        GetOptions( $self->{opt}, @{ $self->{opt_str} || [] } );
    }

    return $self;   
}

sub dhelp {
    my ($self) = @_;

    my $s = qq{

    USAGE
        $Script OPTIONS
    OPTIONS

    EXAMPLES
        $Script --run
    };

    print $s . "\n";

    return $self;   
}

sub run {
    my $self = shift;

    $self
        ->get_opt
        ->read_data
        ->tk_run
        ;

    return $self;
}

sub tk_run {
    my $self = shift;

    my $mw = MainWindow->new;
    
    $self->tk_proc($mw, @_) if $self->can('tk_proc');

    MainLoop;

    return $self;
}

sub _data_file {
    my $self = shift;

    my $data_file = catfile( $self->{root_dir}, $self->{script_name} . '_data.json' );
    return $data_file;
}

sub read_data {
    my $self = shift;
    
    my $data_file = $self->_data_file;

    if (! -e $data_file) {
        return $self;
    }
    my $data_json = read_file($data_file);
    $data_json =~ s/\\"/"/g;

    my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
    $self->{data} = $coder->decode($data_json);

    return $self;
}

1;
