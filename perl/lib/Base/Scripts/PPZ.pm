
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
use File::Slurp::Unicode;

use Plg::Projs::Tex qw(texify);

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
        sects => {
            sub  => 'paragraph',
            pack => 'subsection',
        },
        data => {},
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
        "file_out|o=s",
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

    my ($scr_bn) = ($Script =~ /^(.*)\.(\w+)$/g );

    my $scr = $^O eq 'MSWin32' ? $scr_bn : $scr_bn . '.sh';
    my $s = qq{

    LOCATION
        $0
    USAGE
        $Script OPTIONS
    OPTIONS
        -f --file FILE
        -o --file_out FILE
        -m --module MODULE

    EXAMPLES
        $scr --file FILE
        $scr -m File::Slurp -o 1.tex
    };

    print $s . "\n";

    return $self;   
}

sub tex_write_f {
    my ($self) = @_;

    my $fo = $self->{file_out};

    if ($fo) {
        write_file($fo,join("\n",$self->_tex_lines) . "\n");
    }

    return $self;   
}

=head3 _subnames($pack)

List of subroutines for the given package

=cut

sub _subnames {
    my ($self, $pack) = @_;

    return sort keys %{$self->{data}->{$pack} || {}};

    return $self;   
}

=head3 _subnames()

List of packages

=cut

sub _packages {
    my ($self) = @_;

    return sort keys %{$self->{data} || {}};
}

sub _tex_lines {
    my ($self) = @_;

    @{$self->{tex_lines} || []};
}

sub _sect {
    my ($self,$type) = @_;

    my $sect = $self->{sects}->{$type};

    return $sect;

}

sub tex_push {
    my ($self,$lines) = @_;

    $self->{tex_lines} ||= [];

    if ($lines && @$lines) {
        push @{$self->{tex_lines}}, @$lines;
    }

    return $self;   
}

sub load_f_ppi_to_data {
    my ($self, $file) = @_;

    $self->{tex} ||= [];
    my $sect = q{paragraph};

    my $doc = PPI::Document->new($file);

    $doc->index_locations;

    my $f = sub { 
        $_[1]->isa( 'PPI::Statement::Sub' ) 
        || $_[1]->isa( 'PPI::Statement::Package' )
        || $_[1]->isa( 'PPI::Statement::Variable' )
        || $_[1]->isa( 'PPI::Statement::Include' )
    };
    my @nodes = @{ $doc->find( $f ) || [] };

    my( $pack, $subname_short, $subname_full );
    my $add = {};
    $add->{$_} = 1 for(qw(vars subs packs));

    for my $node (@nodes){

        #$node_count++;
        #last if ( $max_node_count && ( $node_count == $max_node_count ) );

###PPI_Statement_Sub
        $node->isa( 'PPI::Statement::Sub' ) && do { 
            next unless $add->{subs};

            $pack ||= 'main'; 
            $subname_full  = $pack . '::' . $node->name;
            $subname_short = $node->name; 

            my $subname_tex = texify($subname_short,'rpl_special');
            $self->tex_push([ 
                sprintf(q{\%s{%s}}, $self->_sect('sub'), $subname_tex),
                '',
            ]);

            my $code = $node->block->content;
            $self->{data}->{$pack} ||= {};
            $self->{data}->{$pack}->{$subname_short} ||= {};
            $self->{data}->{$pack}->{$subname_short}->{code} = $code;

            if ($code) {
                $self->tex_push([ 
                    q{\begin{verbatim}}, 
                    split("\n" => $code),
                    q{\end{verbatim}}, 
                ]);
            }
        };
###PPI_Statement_Variable
        $node->isa( 'PPI::Statement::Variable' ) && do { 
            next unless $add->{vars};

            my $type = $node->type;
            next unless $type eq 'our';

            my @a = ($pack,$file,$type);

            my $vars = [ $node->variables ];
        };
###PPI_Statement_Package
        $node->isa( 'PPI::Statement::Package' ) && do { 
            $pack = $node->namespace; 

            $self->{data}->{$pack} ||= {};


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
        $self->load_f_ppi_to_data($file);
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

sub data_to_tex {
    my ($self) = @_;

    foreach my $pack ($self->_packages) {
        $self->tex_push([ 
           sprintf(q{\%s{%s}}, $self->_sect('pack'), texify($pack,'rpl_special')),
           ' ',
        ]);
    }

    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->get_opt
        ->load_f
        ->data_to_tex
        ->tex_write_f
        ;
    
    $self;
}

1;
 

