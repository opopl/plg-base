
package Base::DB;

=head1 NAME

Base::DB

=head1  SYNOPSIS

	use Base::DB qw(:funcs :vars);

=cut

use strict;
use warnings;

use base qw(Exporter);

###export_vars_scalar
my @ex_vars_scalar=qw(
	$DBH
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw();

my %EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
	dbh_insert_hash
	dbh_select
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

our $DBH;

=head1 EXPORTED VARS

	$DBH

=head1 EXPORTED FUNCTIONS

=cut

sub dbh_select {
	my ($ref)=@_;

	my $dbh = $ref->{dbh} || $DBH;
	my $warn = $ref->{warn} || sub {  warn $_ for(@_); };

	# fields
	my @f = @{$ref->{f} || []};

	# params
	my @p = @{$ref->{p} || []};

	# table
	my $t = $ref->{t} || '';

	# additional conditions
	my $cond = $ref->{cond} || '';

	my $e = q{`};
	my $f = join ',' => map { $e . $_ . $e } @f;
	my $q = qq| 
		SELECT `$f` FROM `$t` $cond
	|;
	# query if input
	$q = $ref->{q} if $ref->{q};

	my $sth;
 	eval { $sth	= $dbh->prepare($q); };
	if($@){ $warn->($@,$dbh->errstr,$q);  }
	
	eval { $sth->execute(@p) or do { $warn->($dbh->errstr,$q,@p); }; };
	if($@){ $warn->($@,$dbh->errstr,$q,@p); }

	my $rows=[];
	while (my $row=$sth->fetchrow_hashref()) {
		push @$rows,$row;
	}
	return $rows;
}

=head2 dbh_insert_hash 

=head3 Usage

	dbh_insert_hash({ dbh => $dbh, h => $hash, t => $table });

=head3 Purpose

	insert hash of value into table.

=cut

sub dbh_insert_hash {
	my ($ref)=@_;

	my $dbh = $ref->{dbh} || $DBH;
	my $warn = $ref->{warn} || sub {  warn $_ for(@_); };

	my $h = $ref->{h} || {};
	my $t = $ref->{t} || '';

	my $INSERT = $ref->{i} || 'INSERT';

	unless (keys %$h) {
		return;
	}

	my $ph = join ',' => map { '?' } keys %$h;
	my @f = keys %$h;
	my @v = map { $h->{$_} } @f ;
	my $e = q{`};
	my $f = join ',' => map { $e . $_ . $e } @f;
	my $q = qq| 
		$INSERT INTO `$t` ($f) VALUES ($ph) 
	|;
	my $ok = eval {$dbh->do($q,undef,@v); };
	if ($@) {
		$warn->($@,$q,$dbh->errstr);
		return;
	}

	return $ok;
}

1;
 

