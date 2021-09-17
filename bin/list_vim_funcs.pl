#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use File::Find qw(find);

my $plg = $ENV{PLG};

my @files;
my @exts=qw();
my @dirs;
push @dirs,;

find({ 
	wanted => sub { 
	foreach my $ext (@exts) {
		if (/\.$ext$/) {
			push @files,$File::Find::name;
		}
	}
	} 
},@dirs
);
