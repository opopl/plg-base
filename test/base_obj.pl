#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Plg::Projs::Build::Maker::Jnd::Processor;
my $p = Plg::Projs::Build::Maker::Jnd::Processor->new( a => 2 );

package A;

use base qw(Base::Obj);


sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

package main;

my $a = A->new(a => { b => 10 });
print Dumper($a->_val_('a')) . "\n";

my $c = {};
my $d = $c->{1};
