package Base::VH;

use strict;
use warnings;

use Exporter ();
use base qw(Exporter);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA     = qw(Exporter);
@EXPORT  = qw( );
$VERSION = '0.01';

use Base::String qw(
	str_split
);

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
		vh_decl
		vh_tags
		vh_links
		vh_untag
	)],
	'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub vh_tags {
	my (@args) = @_;

	my @tags;

	for my $arg (@args){	
		push @tags, map { '*'.$_.'*' } str_split($arg);
	}

	@tags;
}

sub vh_links {
	my ($arg) = @_;

	my @links = map { '|'.$_.'|' } str_split($arg);

	@links;
}

sub vh_untag {
	my (@tags) = @_;

	map { s/^\s*\*(.*)\*\s*$/$1/g; $_ } grep { defined } @tags;
}

sub vh_decl {
	'vim:ft=help:foldmethod=indent:fenc=utf8:tw=78:';
}

1;
 

