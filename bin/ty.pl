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
use File::Spec::Functions qw(catfile);
use File::Slurp qw(append_file);
use File::Path qw(rmtree);

use Cwd qw(abs_path getcwd);

our(%OPTDESC);
use vars qw(
	$CMDLINE %OPT
	@OPTSTR
);

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }


}

sub logfile {
	my $self=shift;

	my $logfile = catfile(getcwd(),'ty.log');

	return $logfile;
}
      
sub get_opt {
	my $self=shift;
	
	Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
	
	@OPTSTR=( 
		"tfile=s",
		"dir=s@" ,
		"add=s@" ,
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
		--dir DIR1 --dir DIR2   (array)

S
	print $s . "\n";

	$self;
}

sub run_pf {
	my $self=shift;

	my @dirs = map { abs_path($_) } @{ $OPT{dir} || [] };
	my $tfile = $OPT{tfile} || catfile(getcwd(),'tygs');

	unless (@dirs) {
		$self->warn('no dirs!'); return $self;
	}

	unless ($tfile) {
		$self->warn('no tfile!'); return $self;
	}

	my $logfile = $self->logfile;
	rmtree $logfile if -e $logfile;

	print 'logfile:   ' . $logfile ."\n";
	print 'tagfile:   ' . $tfile ."\n";

	my %o = (
		dirs     => \@dirs,
		tagfile  => $tfile,
		sub_log  => sub { 
			append_file($logfile,join("\n",@_) . "\n");
		},
		sub_warn => sub { 
			append_file($logfile,join("\n",map { 'WARN ' . $_ } @_) . "\n");
			warn $_ . "\n" for(@_);
		},
		add => [qw( subs packs vars include )],
	);

	@{$o{add}}=split(',', join(',' , @{ $OPT{add} } )) if $OPT{add};


	my $pf = Base::PerlFile->new(%o);

	$pf
		->load_files_source
		->ppi_process
		->tagfile_rm
		->write_tags
	;

	$self;
}

sub main {
	my $self=shift;

	$self
		->get_opt
		->run_pf;

	$self;

}

package main;

ty->new->main;
