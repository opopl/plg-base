#!/usr/bin/env perl 
#
package cnv;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use File::Spec::Functions qw( catfile abs2rel );
use File::Find qw(find);

use File::Slurp::Unicode;

use File::Path qw(mkpath);
use File::Basename qw(basename dirname);

use HTML::HTML5::Writer;
use XML::LibXML;

use Base::HTML::Page;

use HTML::Toc;
use HTML::TocInsertor;

my $space = '__space__';
my $hr    = '__hr__';
my $br    = '__br__';

my @sel;
#push @sel,
    #q{base#act#dict_view}
;

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my ($self) = @_;

    my $plg_root = $ENV{PLG} || catfile($ENV{VIMRUNTIME},qw(plg));
    my $plg      = shift @ARGV || 'base';
    
    my $plg_dir  = catfile($plg_root,$plg);
    my $html_dir = catfile($ENV{HTMLOUT},qw( plg ) );
    mkpath $html_dir;

    my $h = {
        plg       => $plg,
        plg_dir   => $plg_dir,
        html_dir  => $html_dir,
        num_files => 0,
    };
        
    my @k = keys %$h;

    for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->find_files
        ->get_funcs
        ->html_make
        ->html_toc
        ->html_write2file
        ;

    return $self;
}



sub find_files {
    my ($self) = @_;

    my @files;
    my @exts = qw(vim);
    
    my @dirs;
    push @dirs, $self->{plg_dir};
    
    foreach my $dir (@dirs) {
        find({ 
            wanted => sub { 
            foreach my $ext (@exts) {
                if (/\.$ext$/) {
                    my $path = $File::Find::name;
                    if ($^O eq 'MSWin32') {
                      $path =~ s{\/}{\\}g;
                    }
        
                    push @files,abs2rel($path,$self->{plg_dir});
                }
            }
            } 
        },$dir
        );
    
    }

    $self->{files} = \@files;

    return $self;
}

sub html_make {
    my ($self) = @_;

    my $funcs = $self->{funcs} || {};

    my $plg = $self->{plg};

    my $pg = Base::HTML::Page->new(
        title => $plg
    );

    #my @funcs = sort { length($b) <=> length($a) } keys %$funcs;
    my @funcs = sort  keys %$funcs;
    #print Dumper(\@funcs) . "\n";

    foreach my $func (@funcs) {
        my $v = $funcs->{$func};

        next unless $func;

        #if (@sel) {
            #next unless (grep { /^$func$/ } @sel);
        #}

        my $lines = $v->{lines};
        my $dec   = $v->{dec};

        my $i=0;
        my @lines_num = map { $i++; sprintf("%s %s %s",$i,$space,$_) } @$lines;

        $pg
            ->add('h1',{ 
                text  => $func,
                attr  => { id => $func },
            })
            ->add('br') 
            ->add('a',{ 
                text  => 'TOC',
                attr  => { href => '#toc' },
            })
            ->add('br') 
            ->add('code',{ 
                text  => join("$br\n",@$dec),
                attr  => { id => "code_dec_$func" },
            })
            ->add('br') 
            ->add('div',{ 
                attr  => { 
                    id    => "div_code_body_$func",
                    class => "div_code_body",
                },
            })
            ->update({ 
                xpath  => sprintf(q{//div[@id="div_code_body_%s"]},$func),
                sub    => sub { 
                    my ($n) = @_;

                    my $e = $pg->{dom}->createElement('code');

                    my $text = join("$br\n",@lines_num);

                    $e->appendText($text);
                    $e->{id} = "code_body_$func";

                    $n->appendChild($e);

                    return $n;
                }
            })
        ;
    }

###css
    my @css;
    push @css,
        qq| .func { background-color: blue; } |,
        qq| .func { color: white; } |,
        ;
    $pg->css({ css => \@css });

    my $ln={};
    my $txt={};

    my $str = $pg->_str({ 
        text_update => sub {
            s/$br/<br>/g;
            s/$hr/<hr>/g;
            s/$space/&nbsp;/g;
        },
        line_update => sub {
            m/<code id="code_body_([#\w]+)">/ && do {
                $ln->{is_code} = 1; return;
            };

            m{</code>} && $ln->{is_code} && do {
                $ln->{is_code} = 0;
                return;
            };

            if ($ln->{is_code}) {
                foreach my $f (@funcs) {
                    next unless $f;
                    my $href = sprintf(q{<a href="#%s"><span class="func">%s</span></a>},$f,$f);
                    s{(?<=[\W^#])$f(?=[\W^#])}{$href}g;
                }
            }
        }
    });

    $self->{html} = $str;

    return $self;
}

sub html_toc {
    my ($self) = @_;

    my $toc         = HTML::Toc->new();
    my $tocInsertor = HTML::TocInsertor->new();

    $toc->setOptions({
        'footer'     => '</div>',
        'header'     => '<div class="toc"> <h1 id="toc">Table of Contents</h1>',
    });

    my $html = $self->{html};
    
    $tocInsertor->insert($toc, $html, { 'output' => \$html });
    $self->{html} = $html;

    return $self;
}

sub html_write2file {
    my ($self) = @_;

    my $html_dir = $self->{html_dir};
    my $html_file = catfile($html_dir,'index.html');

    write_file($html_file,$self->{html} . "\n");

    return $self;
}


sub get_funcs {
    my ($self) = @_;

    my $plg_dir = $self->{plg_dir};
    my @files   = @{$self->{files} || [] };

    chdir $plg_dir;
    
    my $funcs;

    my $num_files = $self->{num_files};
    
    my $j_f = 0;
    
    my $last_file;
    foreach my $file (@files) {
        my $path = catfile($plg_dir,$file);
    
        my @lines = read_file $path;
    
        my ($f_now, $is_f);
        $f_now = '';
        
        my %is_f;

        my $push = sub {
            my ($input, $where) = @_;

            $where ||= 'lines';

            $funcs->{$f_now} ||= {};
            $funcs->{$f_now}->{'lines'} ||= [];
            $funcs->{$f_now}->{'dec'} ||= [];
            $funcs->{$f_now}->{'help'} ||= [];

            for my $a (@$input){
                $a =~ s/\s/$space/g;
                push @{$funcs->{$f_now}->{$where}}, $a;
            }
        };

        my $lnum = 0;
        my $level_f = 0;
        for(@lines){
            chomp;

            $lnum++;

            m/^\s*fun(?:|ction)!\s*([#\w]+)\s*\(.*\)\s*$/g && do {
                my $f = $1;
                my $a = $2;

                $level_f++;

                next if $f =~ /^[\w\.]+$/;

                $f_now = $f;

                $is_f{dec}  = 1;
                $is_f{body} = 1;

                $funcs->{$f_now}->{file} = $file;

                $push->([$_, $hr],'dec');
                $is_f{dec} = 0; 
                next;
    
            };

            m/^\s*fun(?:|ction)!.*$/g && do {
                $level_f++;
            };

            m/^\s*endf(|un|unction)\s*$/g && do {
                my @input;

                $level_f--;

                unless($level_f){
                    $is_f{body} = 0;
                    push @input, $hr ;
                }
                    
                push @input, $_ ;
                $push->(\@input);
                next; 
            };

            if ($is_f{body}) {
                $push->([$_]);
            }
    
        }
    
        $j_f++;
    
        if ($num_files && $j_f == $num_files){
            last;
        }
    
    }

    $self->{funcs} = $funcs;

    #print Dumper [sort keys %$funcs];
    #foreach my $s (@sel) {
        #print Dumper $funcs->{$s};
    #}

    return $self;

}

package main;

use base qw(cnv);

__PACKAGE__->new->run;


