#!/usr/bin/env perl 
#
package pod_process;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use File::Spec::Functions qw(catfile);
use File::Find qw(find);
use File::Path qw(make_path remove_tree);
use File::Basename qw(basename dirname);

use Getopt::Long qw(GetOptions);
use FindBin qw($Bin $Script);

use Base::Pod;
use Class::Inspector;

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

sub get_opt {
	my ($self) = @_;
	
	Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
	
	@OPTSTR=( 
		"module|m=s",
		"file|f=s",
		"run",
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
	my ($self) = @_;

	my $s = qq{

	USAGE
		$Script OPTIONS
	OPTIONS
		--run

		--module -m      MODULE        (string)
		--file   -f      FILE
	EXAMPLES
		$Script --run --file FILE
		$Script --run --module MODULE

};

	print $s . "\n";

	$self;
}

sub init_vars {
	my ($self) = @_;

	$self;
}

sub main {
	my ($self) = @_;

	$self
		->get_opt
		->init_vars;

	my $pp = Base::Pod->new;

	my $file   = $OPT{file} || '';
	my $module = $OPT{module} || '';

	unless ($file) {
		if ($module) {
			$file = Class::Inspector->resolved_filename($module);
		}
	}

	$pp->set_source($file);
	$pp->run;

	$self;
}

package main;

pod_process->new->main;
