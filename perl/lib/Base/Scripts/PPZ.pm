
package Base::Scripts::PPZ;

use strict;
use warnings;
use utf8;

binmode STDOUT,':encoding(utf8)';

use Data::Dumper qw(Dumper);
use PPI;

use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);

use Getopt::Long qw(GetOptions);
      
sub get_opt {
    my ($self) = @_;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    my (@optstr, %opt);
    @optstr = ( 
        "help|h",
        "file|f=s",
        "module|m=s",
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
        $Script OPTIONS
    OPTIONS
		-f --file FILE
		-m --module MODULE

    EXAMPLES
        $Script --file FILE
        $Script -m File::Slurp
    };

    print $s . "\n";

    return $self;   
}

1;
 

