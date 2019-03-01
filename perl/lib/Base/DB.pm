
package Base::DB;

=head1 NAME

Base::DB

=head1  SYNOPSIS

	use Base::DB qw(:funcs :vars);

=cut

use strict;
use warnings;

use base qw(Exporter);

use SQL::SplitStatement;

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
	dbh_do
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

our ($DBH,$WARN);

=head1 EXPORTED VARS

	$DBH

=head1 EXPORTED FUNCTIONS

=cut

=head2 dbh_select 

=head3 Usage

	my $ref={
		# table
		t => TABLE,
		# fields
		f => [ FIELD1, FIELD2, ... ],
		# params
		p => [ ... ],
		# additional conditions
		cond => [ ... ],
	};
	my $rows = dbh_select($ref);

=cut

sub dbh_select {
	my ($ref)=@_;

	my $dbh = $ref->{dbh} || $DBH;
	my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

	# fields
	my @f = @{$ref->{f} || []};

	# params
	my @p = @{$ref->{p} || []};

	# table
	my $t = $ref->{t} || '';

	# additional conditions
	my $cond = $ref->{cond} || '';

	my $SELECT = $ref->{s} || 'SELECT';

	my $e = q{`};
	my $f = join ',' => map { $e . $_ . $e } @f;
	my $q = qq| 
		$SELECT $f FROM `$t` $cond
	|;
	# query if input
	$q = $ref->{q} if $ref->{q};

	my $sth;
 	eval { $sth	= $dbh->prepare($q); };
	if($@){ $warn->($@,$dbh->errstr,$q);  }

	if (not defined $sth) {
		my @w;
		push @w,
			'sth undefined!','query:',$q,'params:',@p,'dbh->errstr=',$dbh->errstr;
		$warn->(@w);
		return [];
	}
	
	eval { $sth->execute(@p) or do { $warn->($dbh->errstr,$q,@p); }; };
	if($@){ $warn->($@,$dbh->errstr,$q,@p); }

	my $rows=[];

	while (my $row = $sth->fetchrow_hashref()) {
		push @$rows,$row;
	}

	return $rows;
}

sub dbh_selectall_arrayref {
	my ($ref)  = @_;

	my $dbh = $ref->{dbh} || $DBH;
	my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

	# query
	my $q   = $ref->{q} || '';

	# params
	my $p   = $ref->{p} || [];

	my $res = [];

	my $spl = SQL::SplitStatement->new;
	my @q   = $spl->split($q);

	for my $q (@q){
		my $rows;
		eval { $rows = $dbh->selectall_arrayref($q) or 
			do { $warn->($q,$dbh->errstr);  };
		}; 
		if ($@) { $warn->($q,$@,$dbh->errstr); }

		push @$res,{ 
			q    => $q,
			rows => $rows,
			err  => $dbh->err ? [$dbh->errstr] : [],
		};
	}

	return $res;

}

=head2 dbh_insert_hash 

=head3 Usage

	dbh_insert_hash({ 
		# database handle
		dbh => $dbh, 

		# input hash of values
		h => $hash, 

		# table name
		t => $table,

		# insert command (optional)
		# 	default is 'INSERT'
		i => 'INSERT OR IGNORE',

		# subroutine for warnings (optional)
		# 	default is:
		# 		sub { warn $_ for(@_); }
		warn => sub { ... },
	});

=head3 Purpose

	insert hash of values into table.

=cut

sub dbh_insert_hash {
	my ($ref)=@_;

	my $dbh = $ref->{dbh} || $DBH;
	my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

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

=head2 dbh_do

=head3 Usage

=cut

sub dbh_do  {
	my ($ref)=@_;

	my $dbh = $ref->{dbh} || $DBH;
	my $warn = $ref->{warn} || $WARN || sub { warn $_ for(@_); };

	my $q = $ref->{q} || '';
	my $p = $ref->{p} || [];

	my $spl = SQL::SplitStatement->new;
	my @q = $spl->split($q);

	my $OK = 1;

	foreach my $query (@q) {
		my $ok;
		eval { $ok = $dbh->do($query); };
		$OK=0 unless $ok;
		if ($@) {
			my @w; 
			push @w,
				map { ( $_->[0] => $_->[1] ) }   (
					[ 'Query:', $query ],
					[ 'Query parameters:', Dumper($p) ],
					[ 'DBI $dbh->errstr:', $dbh->errstr ],
					[ 'Captured error output:', $@ ]
				)
				;
			$warn->(@w);
		}

	}
	return $OK;
}

1;
 

