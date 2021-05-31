#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);


sub get_table {
    my ($ref) = @_;

    $ref ||= {};
    my $attr  = $ref->{attr} || {};
    my $tbody = $ref->{tbody} || {};
    my $tbody_tr = $tbody->{tr} || [];

    my $attr_string = join ' ' => map { qq{$_="$attr->{$_}"} } keys %$attr;

    my $tbody_tr_string='';
    foreach my $tr (@$tbody_tr) {
       next unless $tr;

       $tbody_tr_string .= qq{<tr> $tr </tr>\n};
    }

    my $tbody_string = qq{<tbody>\n$tbody_tr_string</tbody>};

    my $html = qq{ <table $attr_string> \n $tbody_string \n </table> };

    return $html;
}

           #<table width="600" cellspacing="0" cellpadding="0" border="0">

my $t = get_table({ 
	attr => { 
		width => "600",
		cellspacing => "0",
		cellpadding => "0",
		border => "0",
	},
	tbody => {
		tr => [
			'aa',
			'bb',
		]
	}

});
print qq{$t} . "\n";
