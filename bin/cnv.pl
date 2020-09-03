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
        num_files => 5,
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
                    $path =~ s{\/}{\\}g;
        
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

    my %funcs = %{$self->{funcs} || {}};

    my $plg = $self->{plg};

    my $pg = Base::HTML::Page->new(
        title => $plg
    );

    my @funcs = sort keys %funcs;

    my @func_names = keys %funcs;

    foreach my $func (@funcs) {
        my $v = $funcs{$func};

        my $lines = $v->{lines};

        $pg
            ->add('h1',{ 
                text  => $func,
                attr  => { id => $func },
            })
            ->add('a',{ 
                text  => 'TOC',
                attr  => { href => '#toc' },
            })
            ->add('br') 
            ->add('code',{ 
                text => join("__br__",@$lines),
                attr  => { id => "code_$func" },
            })
            ->update({ 
                xpath  => sprintf(q{//code[@id='code_%s']/text()},$func),
                sub    => sub { 
                    my ($n) = @_;

                    my $text = $n->getData;

					#foreach my $func_name (@func_names) {
                        ##$text =~ s{\Q($func_name)\E}{<a href="#$1" class="func">$1</a>}g;
                        #$text =~ s{base#varget}{<a href="#$1" class="func">$1</a>}gms;
                    #}
                    #$text =~ s{(base#varget)}{__tgo__a__ $1}gms;
                    #$text =~ s{(base#varset)}{<a href="#$1" class="func">$1</a>}gms;
                    #print Dumper($text) . "\n";

                    #$text->replaceDataRegEx( $search_cond, $replace_cond, $reflags );

                    #$n->setData($text);
                    return $n;
                }
            })
        ;
    }

    my $str = $pg->_str({ 
        after => sub {
            s/__br__/<br>/g;
            s/__hr__/<hr>/g;
            s/__space__/&nbsp;/g;
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
    
    my $j_f = 0;
    
    my $last_file;
    foreach my $file (@files) {
        my $path = catfile($plg_dir,$file);
    
        my @lines = read_file $path;
    
        my ($f_now, $is_f);
        
        my %is_f;

        my $push = sub {
            my @args = @_;

            $funcs->{$f_now} ||= { 'lines' => [] };
            for my $a (@args){
                push @{$funcs->{$f_now}->{lines}}, $a;
            }
        };

        my $lnum = 0;
        for(@lines){
            chomp;

            $lnum++;

            m/^\s*fun(?:|ction)!\s*([\w\#]+)\s*\(.*\)\s*$/g && do {
                my $f = $1;
                my $a = $2;
                next if $f =~ /^[\w\.]+$/;

                $f_now = $f;

                $is_f{dec}  = 1;
                $is_f{body} = 1;
    
            };

            m/^\s*endf(?:|un|unction)\s*$/g && do {
                $is_f{end} = 1; 
            };

            s/\s/__space__/g;
    
            if ($is_f{body}) {
    
                $funcs->{$f_now}->{file} = $file;

                if ($is_f{dec}) { 
                    $push->($_, '__hr__');

                    $is_f{dec} = 0; 
                    next; 
                }

                if ($is_f{end}) { 
                    $push->('__hr__', $_);

                    $is_f{body} = 0;
                    $is_f{end}  = 0; 
                    next; 
                }

                $push->($_);
            }
    
    
        }
    
        $j_f++;
    
        if ($j_f == $self->{num_files}){
            last;
        }
    
    }

    $self->{funcs} = $funcs;

    return $self;

}

package main;

use base qw(cnv);

__PACKAGE__->new->run;


