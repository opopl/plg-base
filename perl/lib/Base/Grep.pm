package Base::Grep;

use strict;
use warnings;

use Base::Arg qw( hash_inject );
use Getopt::Long qw(GetOptions);
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);

use File::Find::Rule;
      
sub get_opt {
    my ($self) = @_;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    my (@optstr, %opt);
    @optstr = ( 
        "help|h=s",
        "cmd|c=s",
    );
    
    unless( @ARGV ){ 
        $self->dhelp;
        exit 0;
    }else{
        GetOptions(\%opt,@optstr);
        $self->{opt} = \%opt;
    }

    foreach my $k (keys %opt) {
        $self->{$k} = $opt{$k};
    }

    return $self;   
}

sub dhelp {
    my ($self) = @_;

    my $s = qq{

    USAGE
        perl $Script OPTIONS
    OPTIONS

    EXAMPLES
        perl $Script ...

    };

    print $s . "\n";

    return $self;   
}

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my ($self) = @_;
    
    #$self->SUPER::init();
    
    my $h = {};
        
    hash_inject($self, $h);

    return $self;
}

sub run {
    my ($self) = @_;

    $self->get_opt;

    return $self;
}

1;
 

