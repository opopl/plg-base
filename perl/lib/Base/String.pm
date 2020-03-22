
package Base::String;

use strict;
use warnings;

=head1 NAME

Base::String - module for working with strings

=cut

use Exporter ();
use base qw(Exporter);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use String::Util qw(trim);

@ISA     = qw(Exporter);
@EXPORT  = qw( );
$VERSION = '0.01';

###export_vars_scalar
my @ex_vars_scalar=qw(
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
	'funcs' => [qw( 
		str_split
		str_split_trim
		str_split_pm
		str_sum
		str_eq
	)],
	'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub str_split {
	my ($str,$ref) = @_;

	return () unless $str;

	my @res;
	if (ref $str eq "ARRAY"){
		foreach my $s (@$str) {
			push @res, str_split($s);
		}
		return @res;
	}elsif( not ( ref $str eq "" ) ){
		return ();
	}

	$ref ||= {};

	my $c   = $ref->{comment_start}  || '#';
	my $sep = $ref->{sep}  || "\n";

	@res = 
		map { trim($_) } 
		grep { !/^\s*$/ && !/^\s*$c/ } 
		split( $sep => $str );

	wantarray ? @res : \@res;
}

sub str_split_pm {
	my ($str,$ref) = @_;

	return () unless $str;

	my (%pm, @split);

	@split = str_split ($str, $ref);

	for(@split){
		/^\+(.*)/  && do { $pm{$1} ||= 0; $pm{$1}++;  next;  };
		/^\-(.*)/  && do { $pm{$1} ||= 0; $pm{$1}--;  next;  };
		/^(.*)/    && do { $pm{$1} = 1;   next;  };
	}

	return {%pm};
}

sub str_split_trim {
	my ($text) = @_;

	my @a = map { 
		s/^\t*//g; 
		s/^\s*//g; 
		s/\s*$//g; 
		length > 0 ? $_ : ()
	} split "\n" => $text;

	return @a;
}



sub str_eq {
	my ($y,$z)=@_;

	my $ok=1;
	my $h_y = str_split_pm($y);
	my $h_z = str_split_pm($z);

	for (keys %$h_y){
		my $v_z = $h_z->{$_} || 0;
		my $v_y = $h_y->{$_} || 0;
		unless ( $v_y == $v_z ) {
			$ok = 0; last;
		}
	}
	return $ok;
}

sub str_sum {
	my ($old, $new, $ref) = @_;

	my (%sum);

    $old = str_split_pm($old, $ref );
    $new = str_split_pm($new, $ref );

	my @keys = (keys %$old, keys %$new ); 

	for my $k (@keys){
		my $v_new = $new->{$k} || 0;
		my $v_old = $old->{$k} || 0;

		$sum{$k} = $v_old  + $v_new;
	}

	my $s = '';
	while(my($k,$v) = each %sum){
		next unless ($v > 0);

		$s .= "\n" . $k;
	}
	return $s;
}

1;
 

