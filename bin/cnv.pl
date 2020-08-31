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

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my $self = shift;

    my $plg_root = $ENV{PLG} || catfile($ENV{VIMRUNTIME},qw(plg));
    my $plg      = shift @ARGV || 'base';
    
    my $plg_dir  = catfile($plg_root,$plg);
    my $html_dir = catfile($ENV{HTMLOUT},qw(  plg ),$plg);
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
        ->write_to_tmp
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

sub write_to_tmp {
    my ($self) = @_;

    my %funcs = %{$self->{funcs} || {}};
    my $html_dir = $self->{html_dir};

    my $html_file = catfile($html_dir,'index.html');

	my $plg = $self->{plg};

	my $pg = Base::HTML::Page->new(
		title => $plg
	);

    while(my($k,$v)=each %funcs){
        my $func = $k;

        my $lines = $v->{lines};

		$pg
			->add('h1',{ 
				text  => $func,
				attr  => { id => $func },
			})
			->add('code',{ 
				text => join("<br>",@$lines),
			})
		;
    }

    my $str = $pg->_str;
	write_file($html_file,$str . "\n");

    return $self;
}

sub get_funcs {
    my ($self) = @_;

    my $plg_dir = $self->{plg_dir};
    my @files   = @{$self->{files} || [] };

    chdir $plg_dir;
    
    my %funcs;
    
    my $j_f = 0;
    
    my $last_file;
    foreach my $file (@files) {
        my $path = catfile($plg_dir,$file);
    
        my @lines = read_file $path;
    
        my ($f_now, $is_f);
        for(@lines){
            chomp;
    
            m/^\s*function!\s*([\w\#]+)\s*\(.*\)/ && do {
                my $f = $1;
                my $a = $2;
                next if $f =~ /^[\w\.]+$/;
                
                $is_f = 1;
    
                $f_now = $f;
            };
    
            if ($is_f) {
                $funcs{$f_now} ||= { 'lines' => [] };
                push @{$funcs{$f_now}->{lines}}, $_;
    
                $funcs{$f_now}->{file} = $file;
            }
    
            m/^\s*endf/ && do {
                $is_f = 0;
            };
    
        }
    
        $j_f++;
    
        if ($j_f == $self->{num_files}){
            last;
        }
    
    }

    $self->{funcs} = \%funcs;

    return $self;

}

package main;

use base qw(cnv);

__PACKAGE__->new->run;


