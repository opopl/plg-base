#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;


package A;

use Data::Dumper qw(Dumper);

use Hash::Merge qw(merge);
use Base::Arg qw( 
    hash_inject
    hash_merge 
    hash_merge_left
    hash_merge_right
);

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
        tex_exe => 'xelatex',
        insert => {
        },
    };

    my $h_2 = {
        tex_exe => 'pdflatex',
        maps_act => {
            'compile' => 'build_pwg',
            'join'    => 'insert_pwg',
        },
        act_default => 'compile',
        insert => {
            hypertoc   => 1,
            hyperlinks => 1,
        },
    };
    hash_inject($self, $h_1);
    hash_inject($self, $h_2);
        
    return $self;
}


package main;

use base qw(A);

my $a = __PACKAGE__->new;
use Data::Dumper qw(Dumper);

print Dumper($a) . "\n";
