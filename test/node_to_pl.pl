#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use XML::LibXML::Cache;
use XML::LibXML;
use File::Spec::Functions qw(catfile);

use Base::XML qw(
    node_to_pl
);

use Base::Arg qw(
    hash_apply
);

my $xfile = catfile($ENV{P_SR},qw(letopis.bld.usual.xml));


my $cache = XML::LibXML::Cache->new;
my $dom = $cache->parse_file($xfile);


$dom->findnodes('//bld')->map(
        sub { 
            my ($n_bld) = @_;
            my $target = $n_bld->{target};

            $n_bld->findnodes('./opts_maker')->map(
                sub { 
                    my ($n_om) = @_;

                    my $pl = node_to_pl({ 
                        node    => $n_om,
                        listall => 1,
                    });

                }
            );

        }
    );

