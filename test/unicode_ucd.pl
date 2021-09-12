#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Unicode::UCD qw( prop_invmap namedseq );

my (%name, %cp, %cps, $n);
# All codepoints
foreach my $cat (qw( Name Name_Alias )) {
    my ($codepoints, $names, $format, $default) = prop_invmap($cat);
    # $format => "n", $default => ""
    foreach my $i (0 .. @$codepoints - 2) {
        my ($cp, $n) = ($codepoints->[$i], $names->[$i]);
        # If $n is a ref, the same codepoint has multiple names
        foreach my $name (ref $n ? @$n : $n) {
            $name{$cp} //= $name;
            $cp{$name} //= $cp;
        }
    }
}
# Named sequences
{   my %ns = namedseq();
    foreach my $name (sort { $ns{$a} cmp $ns{$b} } keys %ns) {
        $cp{$name} //= [ map { ord } split "" => $ns{$name} ];
    }
}

print Dumper(scalar keys %cp) . "\n";
my $j = 0;

while(my($k,$v)=each %{cp}){
	$j++;
	last if $j == 10;

	print sprintf(q{\N{%s}},$k) . "\n";
}

print "\N{ASSERTION}";
