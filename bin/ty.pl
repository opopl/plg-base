#!/usr/bin/env perl 
#
package ty;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use FindBin qw($Script $Bin);

use lib "$Bin/../perl/lib";

use Getopt::Long qw(GetOptions);
use File::Spec::Functions qw(catfile);
use File::Slurp qw(append_file);
use File::Path qw(rmtree);
use List::MoreUtils qw(uniq);

use Base::PerlFile;

use Cwd qw(abs_path getcwd);

use base qw(Base::Logging);

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
		"db=s",
		"dir=s@" ,
		"add=s@" ,
		"inc",
		"action=s",
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
		--dir DIR1 --dir DIR2    (array)
		--inc 

		--db dbfile

		--action ACTION          (string)
			values:
				generate_from_fs
				generate_from_db
			default: 
				generate_from_fs
	EXAMPLES
		$Script --inc

S
	print $s . "\n";

	$self;
}

sub run {
	my $self=shift;

	$self
		->get_opt
		->run_pf;

	$self;

}

sub run_pf {
	my $self = shift;

	my @dirs =  @{ $OPT{dir} || [] };
	my $tfile = $OPT{tfile} || catfile(getcwd(),'tygs');

	my $dbfile = $OPT{db} || ':memory:';
	if ($OPT{inc}) {
		push @dirs,
			@INC;
	}
	my $action = $OPT{action} || 'generate_from_db';

	unless (@dirs) {
		$self->warn('no dirs!'); return $self;
	}

	@dirs = map { abs_path($_) } @dirs;
	@dirs = uniq(@dirs);

	unless ($tfile) {
		$self->warn('no tfile!'); return $self;
	}

	my $logfile = $self->logfile;
	rmtree $logfile if -e $logfile;

	my @m;
	push @m,
		'logfile:   ',
			"\t" . $logfile,
		'tagfile:   ',
			"\t" . $tfile,
		'dirs:   ',
			( map { "\t" . $_ } @dirs ),
		'dbfile:   ',
			"\t" . $dbfile,
		;
	$self->log([@m]);

	my %o = (
		dirs     => \@dirs,
		tagfile  => $tfile,
		dbfile   => $dbfile,
		def_PRINT  => sub { 
			append_file($logfile,join("\n",@_) . "\n");
		},
		def_WARN => sub { 
			append_file($logfile,join("\n",map { 'WARN ' . $_ } @_) . "\n");
		},
		add => [qw( subs packs vars include )],
	);

	@{$o{add}} = split(',', join(',' , @{ $OPT{add} } )) if $OPT{add};

	my $pf = Base::PerlFile->new(%o);

	my $start = time();
	$pf->$action;
	my $end = time();

	$self->log(['TIME SPENT:',"\t" . ($end-$start)]);

	$self;
}



package main;

ty->new->run;
