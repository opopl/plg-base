
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

use File::Path qw(make_path remove_tree mkpath rmtree);
use File::Spec::Functions qw(catfile);

use Module::Which::List qw/ list_pm_files /;

use Getopt::Long qw(GetOptions);
use Base::Arg qw( hash_inject );
use File::Slurp::Unicode;

use File::Dat::Utils qw(readarr);

use Plg::Projs::Tex qw(texify);

use base qw(
    Base::Obj
);

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
        proj => 'main',
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
        "dir_out|d=s",
        "f_list|l=s",
        "module|m=s",
        "proj|p=s",
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
        -d --dir_out DIR
        -m --module MODULE

    EXAMPLES
        $scr --file FILE
        $scr -m File::Slurp -o 1.tex
        $scr --f_list list.i.dat -o 1.tex
        $scr --f_list list.i.dat -d 1
    };

    print $s . "\n";

    return $self;   
}

sub tex_write_f {
    my ($self) = @_;

    while (1) {
###tex_write_file_out
        $self->{file_out} && do {
            $self->data_to_tex_single;

            my @tex;
            push @tex,
                $self->_tex_preamble,
                $self->_tex_lines,
                $self->_tex_postamble,
                ;
    
            write_file($self->{file_out},join("\n",@tex) . "\n");
            last;
        };

###tex_write_dir_out
        $self->{dir_out} && do {
            my $dir = $self->{dir_out};
            my $proj = $self->{proj};
            mkpath $dir unless -d $dir;

            foreach my $pack ($self->_packages) {
                my $sec = $pack;
                $sec =~ s/::/_/g;
                $sec = lc $sec;

                my $pack_file = catfile($dir,sprintf(q{%s.%s.tex}, $proj, $sec ));

                my $head = sprintf(q{\%s{%s}}, $self->_sect('pack'), texify($pack,'rpl_special'));

                foreach my $sub ($self->_subnames($pack)) {
                }
            }

            last;
        };

        last;
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

sub _tex_postamble {
    my ($self) = @_;

    my $p = q{
\end{document}
    };
    return $p;
}

sub _tex_preamble {
    my ($self) = @_;

    my $p = q{
\documentclass[a4paper,landscape,11pt]{report}
\usepackage{titletoc}
\usepackage{xparse}
\usepackage{p.core}
\usepackage{p.env}
\usepackage{p.rus}
\usepackage{p.secs}
\usepackage{p.toc}
\usepackage[xindy]{imakeidx}
\usepackage{p.hyperref}
\usepackage[hmargin={1cm,1cm},vmargin={2cm,2cm},centering]{geometry}
\usepackage{color}
\usepackage{xcolor}
\usepackage{colortbl}
\usepackage{graphicx}
\usepackage{tikz}
\usepackage{pgffor}
\usepackage[export]{adjustbox}
\usepackage{longtable}
\usepackage{multicol}
\usepackage{filecontents}
\usepackage[useregional]{datetime2}
\usepackage{mathtext}
\usepackage{nameref}
\begin{document}
};
    return $p;
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

            my $code = $node->block->content;
            $self->{data}->{$pack} ||= {};
            $self->{data}->{$pack}->{$subname_short} ||= {};
            $self->{data}->{$pack}->{$subname_short}->{code} = $code;


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

sub load_module {
    my ($self, $ref) = @_;
    $ref ||= {};

    my $module = $ref->{module} || $self->{module} || '';

    return $self unless $module;

    my @libs;
 
    my @data = list_pm_files($module,@libs);
 
    foreach my $item (@data) {
        my $file = $item->{path};
        next unless $file;

        delete $self->{module};
        $self->load_f({ file => $file });
    }
    return $self;
}

sub load_f {
    my ($self, $ref) = @_;
    $ref ||= {};

    my $file   = $ref->{file} || $self->{file} || '';

    my $f_list = $self->{f_list};
    my $module = $self->{module};

    while (1) {
        ($file && -e $file) && do {
            $self->load_f_ppi_to_data($file);
            last;
        };

        ($module) && do {
            $self->load_module({ module => $module });
            last;
        };

        ($f_list && -e $f_list) && do {
            my @list = readarr($f_list);
            foreach my $module (@list) {
                $self->load_module({ module => $module });
            }
            last;
        };

        last;
    }

    return $self;
}

sub data_to_tex_single {
    my ($self) = @_;

    foreach my $pack ($self->_packages) {
        $self->tex_push([ 
           sprintf(q{\%s{%s}}, $self->_sect('pack'), texify($pack,'rpl_special')),
           ' ',
        ]);

        foreach my $sub ($self->_subnames($pack)) {
            my $sub_tex = texify($sub,'rpl_special');

            $self->tex_push([ 
                sprintf(q{\%s{%s}}, $self->_sect('sub'), $sub_tex),
                '',
            ]);

            my $code = $self->_val_(qw(data), $pack, $sub, qw(code));

            next unless $code;
            $self->tex_push([ 
                q{\begin{verbatim}}, 
                split("\n" => $code),
                q{\end{verbatim}}, 
            ]);
        }
    }

    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->get_opt
        ->load_f
        ->tex_write_f
        ;
    
    $self;
}

1;
 

