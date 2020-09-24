#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;


package A;

use Data::Dumper qw(Dumper);

use Hash::Merge qw(merge);
use Base::Arg qw( hash_update );

Hash::Merge::set_behavior('RIGHT_PRECEDENT');


sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my $self = shift;

    my $h = {
        'a' => 'aaa',
        'b' => 'bbb',
    };
    my $m = merge($self, $h);
    print Dumper($m) . "\n";
    hash_update($self, $m);
        
    return $self;
}


package main;

use base qw(A);

my $a = __PACKAGE__->new;

print $a->{a} . "\n";
