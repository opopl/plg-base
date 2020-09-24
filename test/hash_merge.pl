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

    my $h_1 = {
        'a' => { '1' => 'aaa' },
        'b' => 'bbb',
    };
    my $h_2 = {
        'a' => { '1' => 'ccc' },
        'b' => 'bbb',
    };
    hash_update($self, $h_1,{ keep_already_defined => 1 });
    #hash_update($self, $h_2,{ keep_already_defined => 1 });
        
    return $self;
}


package main;

use base qw(A);

my $a = __PACKAGE__->new;
use Data::Dumper qw(Dumper);

print Dumper($a->{a}) . "\n";
