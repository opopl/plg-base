#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use File::Spec::Functions qw( catfile abs2rel );
use File::Find qw(find);
use File::Slurp::Unicode;

use File::Path qw(mkpath);
use File::Basename qw(basename dirname);

my $plg_root = $ENV{PLG} || catfile($ENV{VIMRUNTIME},qw(plg));
my $plg      = shift @ARGV || 'base';

my $plg_dir = catfile($plg_root,$plg);
my $tmp_dir = catfile($ENV{HOME},qw(tmp plg ),$plg);
mkpath $tmp_dir;

my @files;
my @exts = qw(vim);

my @dirs;
push @dirs, $plg_dir;

foreach my $dir (@dirs) {
    find({ 
        wanted => sub { 
        foreach my $ext (@exts) {
            if (/\.$ext$/) {
                my $path = $File::Find::name;
                $path =~ s{\/}{\\}g;
    
                push @files,abs2rel($path,$plg_dir);
            }
        }
        } 
    },$dir
    );

}

chdir $plg_dir;
my $j_f=0;

my %funcs;
FILE: foreach my $file (@files) {
    my $path = catfile($plg_dir,$file);

    my @lines = read_file $path;
    
    my @nlines;

    my ($f_now, $is_f);
    LINE: for(@lines){
        chomp;

        /^\s*function!\s*(?<f>[\w\#]+)/ && do {
            my $f = $+{f};
            
            $is_f = 1;

            $f_now = $f;

        };

        if ($is_f) {
            $funcs{$f_now} ||= { 'lines' => [] };
            push @{$funcs{$f_now}->{lines}}, $_;

            $funcs{$f_now}->{file} = $file;

            next;
        }

        /^\s*endf/ && do {
            $is_f = 0;

            $j_f++;
        };

        last FILE if $j_f == 1;
    }

}

print Dumper(\%funcs) . "\n";

