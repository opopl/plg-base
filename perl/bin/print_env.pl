#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use feature qw/say/;
use autodie;

use FindBin qw($Bin $Script);
use File::Path qw(mkpath rmtree);
use File::Spec::Functions qw(catfile);

my $isWin = $^O eq "MSWin32" ? 1 : 0;

my $sep = $isWin ? ';' : ':';
my $home = $isWin ? $ENV{USERPROFILE} : $ENV{HOME};
my $host = $isWin ? $ENV{COMPUTERNAME} : $ENV{HOSTNAME};

my $configDirName = $isWin ? 'config_win' : 'config_linux' ;
my $configDir = catfile($home,$configDirName,$host);

mkpath $configDir unless -d $configDir;

my $fileEnvName = 'env.txt';
my $fileEnv = catfile($configDir,$fileEnvName);

rmtree $fileEnv if -e $fileEnv;

open (my $ENV, '>', $fileEnv);

# select new filehandle
select $ENV;

my @env = sort keys %ENV;

foreach my $var (@env) {
    my $value = $ENV{$var};
    my @values = split $sep  => $value;

    say "$var";
    foreach my $val (@values) {
        say "  $val" ;
    }
}

select STDOUT;

say "wrote environment variables to:\n\t$fileEnv" if -e $fileEnv;



