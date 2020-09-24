#!/usr/bin/env perl 
#
package A;

use strict;
use warnings;
use utf8;

use base qw(Base::Obj);


use Base::Arg qw( hash_inject );
use Data::Dumper qw(Dumper);
use Deep::Hash::Utils qw(slurp deepvalue );

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my ($self) = @_;

	my $h = {
		'a' => { 'b' => 'c'},
	};
		
	hash_inject($self, $h);
	print Dumper($self->_val_(qw(a b))) . "\n";

	return $self;
}

package main;

use base qw(A);
__PACKAGE__->new;
