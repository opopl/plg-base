
package Base::Logging;

use strict;
use warnings;

use Base::DB qw(
	dbh_insert_hash
);

=head1 VARIABLES

=over 4

=item C<$SUB_LOG>

=back

=cut

my($PRINT,$WARN);

$PRINT = sub { 
	local $_=shift; 
	my $s = (defined) ? $_ : ''; 
	CORE::print($s . "\n") if $s;
}; 

$WARN = sub { 
	local $_ = shift; 
	my $s = (defined) ? $_ : ''; 
	CORE::warn($s . "\n") if $s;
}; 

#================================

sub log_dumper {
	my ($self,@args)=@_;

	for(@args){
		$self->log(Dumper($_));
	}

	return $self;
}

=head2 log_dbh

=head3 Usage

	$OBJ->log_dbh([ 'a', 'b' ],{ 
		pref     => $pref,
		loglevel => $loglevel
	});

	$OBJ->log_dbh([ { msg => 'a', dump => Dumper($a) }, 'b' ],{ 
		pref     => $pref,
		loglevel => $loglevel
	});

=cut

sub log_dbh {
	my ($self,$args,$ref)=@_;

	$args ||=[];
	$ref  ||={};

	my $pref     = $ref->{pref} || '';
	my $loglevel = $ref->{loglevel} || 'log';

	my $msg;
	my $ih = {};
	if (ref $args eq ""){
		$msg  = $pref . $args;

	}elsif(ref $args eq "HASH"){
		my $arg = $args;
		$msg = $arg->{msg};
		$ih  = $arg->{ih} || {};
		
	}elsif(ref $args eq "ARRAY"){
		foreach my $arg (@$args) {
			$self->log_dbh($arg,$ref);
			return $self;
		}
	}	

	my $h = {
		%$ih,
		msg      => $msg,
		time     => time(),
		loglevel => $loglevel,
	};

	if (my $dbh = $self->{dbh}) {
		dbh_insert_hash({ 
			warn => sub {},
			dbh  => $dbh,
			t    => 'log',
			h    => $h,
		});
	}

	return $self;
}

sub log_s {
	my ($self,$arg,$ref,$print)=@_;

	$print ||= $PRINT;

	my $msg;
	if(ref $arg eq "HASH"){
		$msg = $arg->{msg};
		my $ih = $ref->{ih};
	}elsif(ref $arg eq ''){
		$msg = $arg;
	}
		
	$print->($msg);
}

sub log {
	my ($self,$args,@o)=@_;

	#my $sub = $self->{sub_log} || $SUB_LOG || undef;
	#$sub && $sub->(@args);

	$PRINT = $self->{def_PRINT} if $self->{def_PRINT};

	if (ref $args eq "ARRAY"){
		foreach my $arg (@$args) {
			$self->log_s->($arg,@o);
		}
	}else{
		my $arg = $args;
		$self->log_s->($arg,@o);
	}


	for(@$args){
		$self->log_dbh($_,{ loglevel => '' });
	}

	return $self;
}

sub _warn_ {
	my ($self,$args,$ref)=@_;

	#my $sub = $self->{sub_warn} || $SUB_WARN || $self->{sub_log} || $SUB_LOG || undef;
	#$sub && $sub->(@args);

	my $warn = $self->{def_WARN} || $WARN;

	$self->log($args,$ref,$warn);

	for(@$args){
		$self->log_dbh($_,{ loglevel => 'warn' });
	}

	return $self;
}

sub debug {
	my ($self,$args,$ref)=@_;

	return $self unless $self->{debug};

	#my $sub = $self->{sub_log} || $SUB_LOG || undef;
	#$PRINT ||= $self->{def_PRINT};
	#$sub && $sub->(@args);
	#
	my $print = $self->{def_PRINT} || $PRINT;
	$self->log($args,$ref,$print);

	for(@$args){
		$self->log_dbh($_,{ loglevel => 'debug' });
	}

	return $self;
}

1;
 

