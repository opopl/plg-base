#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Text::Sprintf::Named qw(named_sprintf);

use Base::DB qw( 
    dbi_connect 
    dbh_do
    dbh_select
    dbh_select_fetchone
    dbh_insert_hash
);
use File::Spec::Functions qw(catfile);
my $img_root = $ENV{IMG_ROOT};

my $dbfile = catfile($img_root,qw(img.db));

my $r = {
    dbfile => $dbfile,
    attr   => {
    },
};

my $dbh = dbi_connect($r);
$Base::DB::DBH = $dbh;

my $cond = named_sprintf (
	q{ WHERE sec IS NOT NULL AND regex('^(%(date)s)',sec,'g',1) = '%(date)s' },
	#{ date => '12_11_2020' },
	{ date => '10_09_2021' },
);

my $ref = {
	t => qq{imgs},
	f => [ q{ regex('^jpg',extension(img))^ma },  qw( url sec ) ],
	p => [  ],
	#where => { },
	cond => $cond,
	limit => 100,
	#cond => q{ LIMIT 10 },
};

my ($rows, $cols, $q, $p) = dbh_select($ref);
print Dumper($rows) . "\n";
