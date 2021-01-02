
package Base::H;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw( hash_inject );
use Base::DB qw(
    dbh_do
    dbh_insert_hash
    dbh_select
    dbh_select_as_list
    dbi_connect
);
use FindBin qw($Bin $Script);
use Getopt::Long qw(GetOptions);

use base qw(
    Base::Cmd
);


sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

      
sub get_opt {
	my ($self) = @_;
	
	Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
	
	my (@optstr, %opt);
	@optstr=( 
		"cmd|c=s",
		"remote|r=s",
		"local|l=s",
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

	EXAMPLES
		$Script ...

	};

	print $s . "\n";

	return $self;	
}

sub init {
    my ($self) = @_;
    
    #$self->SUPER::init();
    
    my $h = {
    };
        
    hash_inject($self, $h);
    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->get_opt
        ->run_cmd
        ;

    return $self;
}

1;

