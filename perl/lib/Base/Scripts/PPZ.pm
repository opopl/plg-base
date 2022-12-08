
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

use YAML qw(LoadFile);
use Base::String qw(str_env);

use File::Dat::Utils qw(readarr);

use Plg::Projs::Tex qw(texify);

use base qw(
    Base::Obj
    Base::Cmd
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
            sub       => 'paragraph',
            subs      => 'subsubsection',
            code      => 'subsubsection',
            pack      => 'subsection',
            packs     => 'section',
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
        "f_yaml|y=s",
        "module|m=s",
        "proj|p=s",
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

    my ($scr_bn) = ($Script =~ /^(.*)\.(\w+)$/g );

    #my $scr = $^O eq 'MSWin32' ? $scr_bn : $scr_bn . '.sh';
    my $scr = 'base-ppz';
    my $s = qq{

    LOCATION
        $0
    USAGE
        perl $Script OPTIONS
    OPTIONS
        -c --cmd        CMD, available commands:
                            tex_write_fs
                            tex_write_dir

        -f --file       FILE
        -o --file_out   FILE_OUT
        -d --dir_out    DIR_OUT
        -m --module     MODULE
        -p --proj       PROJ

        -y --yaml       FILE_YAML input yaml file

    EXAMPLES
        Writing to a single output file:
            $scr -c tex_write_fs --file FILE
            $scr -c tex_write_fs -m File::Slurp -o 1.tex
            $scr -c tex_write_fs -y 1.yaml -o 1.tex

        Writing to an output directory:
            $scr -c tex_write_dir -y 1.yaml
    };

    print $s . "\n";

    return $self;   
}

sub wf_main {
    my ($self) = @_;

    my (@tex_main);
    push @tex_main,
        ' ',
        $self->_tex_def_ii,
        ' ',
        q{\ii{preamble}},
        ' ',
        q{\begin{document}},
        ' ',
        q{\ii{tabcont}},
        q{\ii{body}},
        ' ',
        q{\ii{index}},
        ' ',
        q{\end{document}},
        ;

    write_file($self->_file_sec('_main_'),join("\n",@tex_main) . "\n");
    return $self;   
}

sub wf_files_make4ht {
    my ($self) = @_;

    my $dir = $self->{dir_out};

    my $p =<< 'eof';

Make:add("xindy", function(par)
	par.idxfile = par.idxfile or par.input .. ".idx"
	local modules = par.modules or {par.input}
	local t = {}
	for k,v in ipairs(modules) do
		t[#t+1] = "-M ".. v
	end
	par.moduleopt = table.concat(t, " ")
	local xindy_call = "xindy -L ${language} -C ${encoding} ${moduleopt} ${idxfile}" % par
	print(xindy_call)
	return os.execute(xindy_call)
end, { language = "english", encoding = "utf8"} )

if mode=="draft" then
    Make:htlatex {}

elseif mode == "index" then
    Make:htlatex {}
    Make:xindy { idxfile = "subs.idx" }
    Make:htlatex {}
    Make:htlatex {}

else
    Make:htlatex {}
    Make:htlatex {}
    Make:htlatex {}
end

eof

    write_file(catfile($dir,$self->{proj} . '.mk4'),$p);
    return $self;   
}


sub wf_mk_pdf {
    my ($self) = @_;

    my $proj = $self->{proj};

    my $p =<< "eof";
#!/bin/bash

run_tex.sh $proj

eof
    my $f = catfile($self->{dir_out},'mk_pdf.sh');
    write_file($f,$p);
    system("chmod +rx $f");

    return $self;   
}


sub wf_cfg {
    my ($self) = @_;

    my @tex_cfg;
    push @tex_cfg, 
        $self->_tex_cfg;

    write_file($self->_file_sec('_cfg_'),join("\n",@tex_cfg) . "\n");

    return $self;   
}

sub wf_packs {
    my ($self) = @_;

    my @tex_packs;

    push @tex_packs,
       sprintf(q{\%s{%s}}, $self->_sect('packs'), 'Packages');
       ; 
    foreach my $pack ($self->_packages) {
        my (@tex);

        my $sec = $pack;
        $sec =~ s/::/_/g;
        $sec = lc $sec;
        $sec = sprintf(q{pack.%s},$sec);

        my $pack_file = $self->_file_sec($sec);
        my $pack_tex = texify($pack,'rpl_special');

        my $subs_file = $self->_file_sec($sec . '.subs');

        my $head_pack = sprintf(q{\%s{%s}}, $self->_sect('pack'), $pack_tex);
        push @tex,$head_pack;

        push @tex_packs,
            sprintf(q{\ii{%s}},$sec);


        my $head_subs = sprintf(q{\%s{%s}}, $self->_sect('subs'), 'Subroutines');
        push @tex,$head_subs;
        foreach my $sub ($self->_subnames($pack)) {
            my $sub_tex = texify($sub,'rpl_special');

            my $head_sub = sprintf(q{\%s{%s}}, $self->_sect('sub'), $sub_tex);
            push @tex,$head_sub;

            my $code = $self->_val_(qw(data), $pack, qw(subs), $sub, qw(code));

            next unless $code;
            push @tex,
                '',
                sprintf(q{\index[subs]{%s!%s}},$sub_tex,$pack_tex),
                '',
                q{\begin{verbatim}}, 
                split("\n" => $code),
                q{\end{verbatim}},
                '',
                ;
        }

#        my $code = $self->{data}->{$pack}->{code} || '';
        #if ($code) {
			#push @tex,
                #'',
				#sprintf(q{\%s{%s}}, $self->_sect('code'), 'Code'),
                #'',
                #q{\begin{verbatim}}, 
                #split("\n" => $code),
                #q{\end{verbatim}},
                #''
                #;
        #}


        write_file($pack_file,join("\n",@tex) . "\n");

    }

    write_file($self->_file_sec('packs'),join("\n",@tex_packs) . "\n");

    return $self;   
}

sub wf_index {
    my ($self) = @_;

    write_file($self->_file_sec('index'),$self->_tex_index);

    return $self;   
}

sub wf_tabcont {
    my ($self) = @_;

my $p =<< 'eof';
\phantomsection
 
\addcontentsline{toc}{chapter}{\contentsname}
\hypertarget{tabcont}{}
 
\tableofcontents
\newpage
eof

    write_file($self->_file_sec('tabcont'),$p);

    return $self;   
}

sub wf_body {
    my ($self) = @_;

    my (@tex_body);

    push @tex_body,
        q{\ii{packs}};

    write_file($self->_file_sec('body'),join("\n",@tex_body) . "\n");

    return $self;   
}

sub wf_preamble {
    my ($self) = @_;

    my (@tex_preamble);

    push @tex_preamble,
        $self->_tex_preamble;

    write_file($self->_file_sec('preamble'),join("\n",@tex_preamble) . "\n");

    return $self;   
}

sub cmd_tex_write_dir {
    my ($self) = @_;

    $self->{dir_out} ||= $self->{pref};
    my $dir  = $self->{dir_out};

    my $proj = $self->{proj};
    mkpath $dir unless -d $dir;

    my $main_file = catfile($dir,$proj . '.tex');

    $self
        ->wf_preamble
        ->wf_main
        ->wf_body
        ->wf_tabcont
        ->wf_index
        ->wf_packs
        ->wf_cfg
        ->wf_mk_pdf
        ->wf_files_make4ht
        ;

    return $self;   
}

sub cmd_tex_write_fs {
    my ($self) = @_;

    while (1) {
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
            $self->tex_write_dir;
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

    return sort keys %{$self->{data}->{$pack}->{subs} || {}};

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

    my $p =<< 'eof';
\end{document}
eof
    return $p;
}

sub _tex_index {
    my ($self) = @_;

    my $p = q{
\cleardoublepage
\phantomsection
\addcontentsline{toc}{chapter}{Subroutine Index}
\printindex[subs]
};
    return $p;
}

sub _tex_def_ii {
    my ($self) = @_;

    my $proj = $self->{proj};

    my $p = q{
\def\PROJ{%s}
\def\ii#1{\InputIfFileExists{\PROJ.#1.tex}{}{}}
};
    $p = sprintf($p,$proj);

    return $p;
    
}

sub _file_sec {
    my ($self, $sec) = @_;
    $sec ||= '_main_';

    my $dir  = $self->{dir_out};
    my $proj = $self->{proj};

    my $f_sec;
    if ($sec eq '_main_') {
        $f_sec = catfile($dir,$proj . '.tex');

    } elsif ($sec eq '_cfg_') {
        $f_sec = catfile($dir,$proj . '.cfg');

    } else {
        $f_sec = catfile($dir,sprintf('%s.%s.tex', $proj, $sec));
    }
    return $f_sec;
}

sub _tex_cfg {
    my ($self) = @_;

    my $p =<< 'eof';
\Preamble{xhtml,frames,4,index=2,next,charset=utf-8,javascript}

% Don't output xml version tag
\Configure{VERSION}{}

\Configure{DOCTYPE}{\HCode{<!DOCTYPE html>\Hnewline}}
\Configure{HTML}{\HCode{<html>\Hnewline}}{\HCode{\Hnewline</html>}}

% We don't want to translate font suggestions with ugly wrappers like
% <span class="cmti-10"> for italic text
\NoFonts

% Set custom page title
%\Configure{TITLE+}{__TITLE_}
%\Configure{TITLE+}{\PROJ}
%https://gist.github.com/stefanozanella/8892211

% Reset <head>, aka delete all default boilerplate
%\Configure{@HEAD}{}

\Css{
  .verbatim,.verb {
    font-weight      : bold;
    background-color : gray;
    color            : white;
  }
} 


\ifOption{frames}{%
    \Configure{frames}%
             {\HorFrames[
                   frameborder="yes" 
                   border="1"  
                   %framespacing="1" 
                   rows="*"]{*,3*}  
               \Frame[ name="tex4ht-menu" frameborder="2" ]{tex4ht-toc}  
               \Frame[ name="tex4ht-main" frameborder="2" ]{tex4ht-body}
             }  
    {\let\contentsname=\empty \tableofcontents}  
}{}

\newcommand{\thealt}{No alt test was set.}
\newcommand{\nextalt}[1]{\renewcommand{\thealt}{#1}}

\Configure{graphics*}{jpg}{
\Picture[\HCode{\thealt}]{\csname Gin@base\endcsname.jpg}}

\Configure{graphics*}{png}{
\Picture[\HCode{\thealt}]{\csname Gin@base\endcsname.png}}
  
\Configure{graphics*}  
{pdf}  
{%
    \Needs{"convert \csname Gin@base\endcsname.pdf \csname Gin@base\endcsname.png"}%  
    \Picture[pict]{\csname Gin@base\endcsname.png}%  
    \special{t4ht+@File: \csname Gin@base\endcsname.png}
}%  

\begin{document}

\EndPreamble
eof
    return $p;
}

sub _tex_dclass {
    my ($self) = @_;

    my $p = q{\documentclass[a4paper,landscape,11pt]{report}};
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

\makeindex[title=Subroutine Index,name=subs]

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

    my( $pack, $subname_short, $subname_full );
    my $add = {};
    $add->{$_} = 1 for(qw(vars subs packs));

    my $f = sub { 
        my $node = $_[1];

        if ($pack && exists $self->{data}->{$pack}->{code}){
            $self->{data}->{$pack}->{code} .= $node->content;
        }

###PPI_Statement_Package
        $node->isa( 'PPI::Statement::Package' ) && do { 
            $pack = $node->namespace; 

            $self->{data}->{$pack} ||= {};
            $self->{data}->{$pack}->{code} ||= '';

            return unless $add->{packs};
        };

###PPI_Statement_Sub
        $node->isa( 'PPI::Statement::Sub' ) && do { 
            return unless $add->{subs};

            $pack ||= 'main'; 
            $subname_full  = $pack . '::' . $node->name;
            $subname_short = $node->name; 

            my $code = $node->block->content;
            $self->{data}->{$pack} ||= {};
            $self->{data}->{$pack}->{subs} ||= {};
            $self->{data}->{$pack}->{subs}->{$subname_short} ||= {};
            $self->{data}->{$pack}->{subs}->{$subname_short}->{code} = $code;
        };

###PPI_Statement_Variable
        $node->isa( 'PPI::Statement::Variable' ) && do { 
            return unless $add->{vars};

            my $type = $node->type;
            return unless $type eq 'our';

            my @a = ($pack,$file,$type);

            my $vars = [ $node->variables ];
        };

        $node->isa( 'PPI::Statement::Include' ) && do {};
    };
    my @nodes = @{ $doc->find( $f ) || [] };


    return $self;   

}

sub load_module {
    my ($self, $ref) = @_;
    $ref ||= {};

    my $module = $ref->{module} || $self->{module} || '';

    return $self unless $module;

    my @libs;
 
    my @data = list_pm_files($module,@libs);
	#print Dumper(\@data) . "\n";
 
    foreach my $item (@data) {
        my $file = $item->{path};
        next unless $file;

        delete $self->{module};
        $self->load_f({ file => $file });
    }
    return $self;
}

sub load_yaml {
    my ($self) = @_;

    my $f_yaml = $self->{f_yaml};
    return $self unless $f_yaml;

    print $f_yaml . "\n";

    ($self->{pref}) = ( basename($f_yaml) =~ m/^(.*)\.yaml$/) ;

    my $data = LoadFile($f_yaml) || {};
    foreach my $x (keys %$data) {
        $self->{$x} = $data->{$x};
    }

	my $paths = $self->{paths};
	foreach my $path (@$paths) {
		$path = str_env($path);
	}
	#print Dumper($self->{paths}) . "\n";

    return $self;
}

sub load_f {
    my ($self, $ref) = @_;
    $ref ||= {};

    my $file   = $ref->{file} || $self->{file} || '';

    my $module  = $self->{module};
    my $modules = $self->{modules};

	#unless (keys %$ref) {
	#print Dumper($self->{paths}) . "\n";
	#print Dumper($self->{files}) . "\n";
	#}


    while (1) {
        # single Perl file
        ($file && -e $file) && do {
            $self->load_f_ppi_to_data($file);
            last;
        };

        # single Perl module, provided via -m option or through input YAML file
        ($module) && do {
            $self->load_module({ module => $module });
            last;
        };

        # list of Perl modules
        ($modules && ref $modules eq 'ARRAY' && @$modules) && do {
            foreach my $module (@$modules) {
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
        ->load_yaml
        ->load_f
        ->run_cmd       # Base::Cmd
        ;
    
    $self;
}

1;
 

