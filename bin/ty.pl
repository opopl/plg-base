#!/usr/bin/env perl 
#
package ty;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use FindBin qw($Script $Bin);

use lib "$Bin/../perl/lib";
use Base::PerlFile;
use Getopt::Long qw(GetOptions);

my $dirs = [];
my $tfile = '';

our(%OPT,@OPTSTR,%OPTDESC);
our($CMDLINE);

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}
      
sub get_opt {
	my $self=shift;
	
	Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
	
	@OPTSTR=( 
		"tfile=s",
		"dir=s@" ,
	);
	
	%OPTDESC=(
		"help"  => "Display help message",
		"tfile" => "Tagfile",
		"dir"   => "Directories",
	);
	
	unless( @ARGV ){ 
		$self->dhelp;
		exit 0;
	}else{
		$CMDLINE=join(' ',@ARGV);
		GetOptions(\%OPT,@OPTSTR);
	}
	$self;
}

sub dhelp {
	my $self=shift;

	my $s= << "S";
	USAGE
		$Script OPTIONS
	OPTIONS
		--help

		--tfile     FILE         (string)
		--tdir DIR1 --dir DIR2   (array)

S
	print $s . "\n";

	$self;
}

my %o = (
		dirs    => $dirs,
		tagfile => $tfile,
		sub_log  => sub { 
			print $_ . "\n" for(@_);
		},
		sub_warn => sub { 
			warn $_ . "\n" for(@_);
		},
		add => [qw( subs packs )],
);

sub main {
	my $self=shift;

	$self->get_opt;

	my $pf =  Base::PerlFile->new(%o);

	$pf
		->load_files_source
		->ppi_list_subs
		->tagfile_rm
		->write_tags
	;

	$self;

}

package main;

ty->new->main;
