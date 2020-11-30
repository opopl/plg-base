#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

binmode STDOUT,':encoding(utf8)';

use Data::Dumper qw(Dumper);

use Plg::Projs::Tex qw(
    texify
);

my @a = (
    q{dsfdf},
    qq{"dsfdf\n"},
    q{"віавіа"віавіа},
);

#foreach my $x (@a) {
    #texify(\$x);
    #print qq{$x} . "\n";
#}
print Dumper(texify('%_a','rpl_special')) . "\n";
