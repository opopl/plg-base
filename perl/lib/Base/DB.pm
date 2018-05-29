
package Base::DB;

use strict;
use warnings;

our $dbh;

sub dbh_insert_hash {
	my ($ref)=@_;

	my $dbh = $ref->{dbh} || $dbh;

	my $h = $ref->{h} || {};
	my $t = $ref->{t} || '';

	unless (keys %$h) {
		return;
	}

	my $ph = join ',' => map { '?' } keys %$h;
	my @f = keys %$h;
	my @v = map { $h->{$_} } @f ;
	my $e = q{`};
	my $f = join ',' => map { $e . $_ . $e } @f;
	my $q = qq| 
		insert into `$t` ($f) values ($ph) 
	|;
	eval {$dbh->do($q,undef,@v); };
	if ($@) {
		#$warn($@,$q,$dbh->errstr);
	}

}

1;
 

