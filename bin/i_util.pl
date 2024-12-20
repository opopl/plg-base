#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use File::Spec::Functions qw(catfile);

my $base = catfile($ENV{VIMRUNTIME}, qw( plg base util perl ));

# https://docstore.mik.ua/orelly/weblinux2/modperl/ch03_09.htm
my %opts = (
    prefix         => $base,
	installprivlib => catfile($base,qw( lib perl )),
	installscript  => catfile($base,qw( bin )),
	installbin     => catfile($base,qw( bin )),
	installsitelib => catfile($base,qw( lib perl5 site_perl )),
	installman1dir => catfile($base,qw( lib perl5 man )),
	installman3dir => catfile($base,qw( lib perl5 man3 )),
);

my @opts;

foreach my $opt (keys %opts) {
	my $dir = $opts{$opt};

	push @opts, sprintf('%s=%s',uc($opt), $dir);
}

my $make = 'dmake';
my $install = 'dmake install';

my $opts = join(" ",@opts);
print $opts . "\n";

my @cmds;
push @cmds,
	sprintf(q{perl Makefile.PL %s},$opts ),
	#$make,
	$install,
	;

foreach my $cmd (@cmds) {
	system("$cmd");
}
