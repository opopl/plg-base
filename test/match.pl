#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

binmode STDOUT,':encoding(utf8)';

use Plg::Projs::Tex qw(
  texify
  %fbicons
  fbicon_igg
);

use Data::Dumper qw(Dumper);
use Plg::Projs::Regex qw(
	match
	%regex
);

#local $_ = 'Mac::NA_MS_asdsad';
#print 'a' if /^(\w+)::(\w+)_MS(?:|_(\w+))$/;
#
#local $_ = ' ig@';
#print $1 if /^\s*(\w+)/;
#
local $_ = '🤬🤯🙂😡🙁';
#$DB::single = 1;
#
my $pat;
$pat = '^\d+\w+';
#$pat = '^(2)(.*)';

#my $d = match($pat,'23434a b');
#print Dumper($d) . "\n";
my $self = {
	d => { 1 => 1 }
};
my $d = $self->{d};
$d->{3} = 3;

print Dumper($self) . "\n";
