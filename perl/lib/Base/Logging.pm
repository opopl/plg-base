
package Base::Logging;

use strict;
use warnings;

use Base::DB qw(
	dbh_insert_hash
);

sub log_dumper {
	my ($self,@args)=@_;

	for(@args){
		$self->log(Dumper($_));
	}

	return $self;
}

sub log_dbh {
	my ($self,$args,$ref)=@_;

	$args ||=[];
	$ref  ||={};

	my $pref     = $ref->{pref} || '';
	my $loglevel = $ref->{loglevel} || 'log';

	my $msg = join "\n" => map { $pref . $_ } @$args;
	if (my $dbh = $self->{dbh}) {
		dbh_insert_hash({ 
			dbh => $dbh,
			t => 'log', 
			h => { 
				msg      => $msg,
				time     => time(),
				loglevel => $loglevel,
			} 
		});
	}

	return $self;
}

sub log {
	my ($self,@args)=@_;

	my $sub = $self->{sub_log} || undef;
	$sub && $sub->(@args);

	$self->log_dbh([@args],{ pref => '', loglevel => 'log' });

	return $self;
}

sub warn {
	my ($self,@args)=@_;

	my $sub = $self->{sub_warn} || $self->{sub_log} || undef;
	$sub && $sub->(@args);

	$self->log_dbh([@args],{ pref => 'WARN ', loglevel => 'warn' });

	return $self;
}

sub debug {
	my ($self,@args)=@_;

	return $self unless $self->{debug};

	my $sub = $self->{sub_warn} || $self->{sub_log} || undef;
	$sub && $sub->(@args);

	$self->log_dbh([@args],{ pref => 'DEBUG ', loglevel => 'debug' });

	return $self;
}

1;
 

