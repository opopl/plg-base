#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath);

use lib "$Bin/../lib";

use Vim::Plg::Base;

my $dbdir = catfile($ENV{HOME},qw(db));
mkpath $dbdir unless -d $dbdir;

my $dbfile = catfile($dbdir,qw( vim_plg_base.db ));

my $sub_log  = sub { print $_."\n" for(@_) };
my $sub_warn = sub { warn $_."\n" for(@_)};

our $plgbase = Vim::Plg::Base->new(
    sub_log    => $sub_log,
    sub_warn   => $sub_warn,
    dbfile     => $dbfile,
    do_get_opt => 1,
)->main;

