#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use Base::Arg qw(
    hash_apply
    dict_exe_cb
    varexp
);
use Base::String qw(
	str_split
);

use Clone qw(clone);

use Test::More;

sub t_vars {
    my $a_z = [( 'a' .. 'z' )];

    my $expected = {
        z0 => {
            a => {
              'a' => $a_z,
              'b' => [],
	          'c' => [
	                   'section',
	                   'section'
	                 ]
            }
        }
    };

    my $vars = {
        sec => 'section',
        zero => 0,
    };

    my $a = {
        a => [@$a_z],
        b => [ map { '$ifvar{zero} ' . $_ } @$a_z],
        c => [
           '$var{sec}',
           '$ifvar{zero} zzz',
           '$ifvar{sec} $var{sec}',
        ]
    };

    my $a0 = dict_exe_cb(clone($a), {
        cb => sub { },
        cb_list => sub { varexp(shift, $vars); },
    });
    is_deeply($a0, $expected->{z0}->{a},'dict_exe_cb + list varexp');
}

#t_vars();
#done_testing();

use charnames ();
#my $name = charnames::viacode(0x03A3);
#my $ch = "\N{U+20BD}";
my $ch = "\N{U+1F3FC}";
#my $name = charnames::viacode();
#print Dumper($name) . "\n";
use Encode;

#print Encode::encode_utf8($ch) . "\n";
#print Encode::decode_utf8($ch) . "\n";
#
use utf8;

#my $str = 'इस परीक्षण के लिए है';
my $str = $ch;

#printf("%04x", ord($ch));

#for my $c (split //, $str) {
    #printf("\\u%04x", ord($c));
#}

my $opts = { ctl => 1 };
#my $k = 'bb @ push, uniq';
my $k = 'b @@aa';
my ($km, $ctl_line) = str_split($k, { 'sep' => '@' });

my %ctl = map { $_ => 1 } str_split($ctl_line, { 'sep' => ',' });
$k = $km if keys(%ctl) && $opts->{ctl};

#print Dumper({ km => $km, ctl_line => $ctl_line }) . "\n";
print Dumper(\%ctl) . "\n";
