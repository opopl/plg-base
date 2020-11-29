
package Base::Scripts::PPZ;

use strict;
use warnings;
use utf8;

binmode STDOUT,':encoding(utf8)';

use Data::Dumper qw(Dumper);
use PPI;

use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper qw(Dumper);

use Module::Which::List qw/ list_pm_files /;

use Getopt::Long qw(GetOptions);
use Base::Arg qw( hash_inject );

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}


sub init {
    my ($self) = @_;
    
    my $h = {
        #<++> => <++>,
        #<++> => <++>,
    };
        
    hash_inject($self, $h);
    return $self;
}
      
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

    LOCATION
        $0
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

sub load_f_ppi {
    my ($self, $file) = @_;

    my $doc = PPI::Document->new($file);

    $doc->index_locations;

    my $f = sub { 
        $_[1]->isa( 'PPI::Statement::Sub' ) 
        || $_[1]->isa( 'PPI::Statement::Package' )
        || $_[1]->isa( 'PPI::Statement::Variable' )
        || $_[1]->isa( 'PPI::Statement::Include' )
    };
    my @nodes = @{ $doc->find( $f ) || [] };

    my( $ns, $subname_short, $subname_full );
    my $add = {};
    $add->{$_} = 1 for(qw(vars subs packs));

    for my $node (@nodes){

        #$node_count++;
        #last if ( $max_node_count && ( $node_count == $max_node_count ) );

###PPI_Statement_Sub
        $node->isa( 'PPI::Statement::Sub' ) && do { 
            next unless $add->{subs};

            $ns ||= 'main'; 
            $subname_full  = $ns . '::' . $node->name;
            $subname_short = $node->name; 

        };
###PPI_Statement_Variable
        $node->isa( 'PPI::Statement::Variable' ) && do { 
            next unless $add->{vars};

            my $type = $node->type;
            next unless $type eq 'our';

            my @a = ($ns,$file,$type);

            my $vars = [ $node->variables ];
        };
###PPI_Statement_Package
        $node->isa( 'PPI::Statement::Package' ) && do { 
            $ns = $node->namespace; 

            next unless $add->{packs};
        };
    }

    return $self;   

}

sub load_f {
    my ($self, $ref) = @_;
    $ref ||= {};

    my $file = $ref->{file} || $self->{file} || '';

    if ($file) {
        $self->load_f_ppi($file);
    }else{
        my $module = $self->{module};
        if ($module) {
            my @libs;
        
            my @data = list_pm_files($module,@libs);
        
            foreach my $item (@data) {
                my $file = $item->{path};
                next unless $file;

                $self->load_f({ file => $file });
            }
            return $self;
        }
    }

    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->get_opt
        ->load_f
        ;
    
    $self;
}

1;
 

