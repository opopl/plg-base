
package Base::HTML;

=head1 NAME

Base::HTML - HTML parsing module

=head1 EXPORTED

=head2 Functions

=over 4

=item * C<xp()>

=item * C<xp_ids()> - list of all available xpath IDs which could be used in C<xp()> function

=item * C<xpath_heads()>

=back

=head1 METHODS

=cut

use strict;
use warnings;

use Exporter ();
use base qw(Exporter);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

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
		xpath_heads
		xp
		xp_ids
	)],
	'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub xpath_heads {
	my @headnums = (1..6);
	my @xp_heads = map { 'self::h'.$_ } @headnums;
	my $xpath    = '//*['.join(' or ', @xp_heads) . ']';

	return $xpath;
}

=head2 xp

=head3 Usage

	my $xpath = xp($xpath_id, [ $ref ]);

C<$ref> should be HASHREF; available keys:

=over 4

=item * repl - HASHREF, contains replacements to be performed inside the given xpath

=back

=head3 Available ids

=over 4

=item * heads

=item * js

=item * img

=item * css

=item * nodes_between_two_comments

=item * base_url

=back

=cut

sub xp {
	my ($id, $ref) = @_;
	$ref||={};

	my $repl = $ref->{repl} || {};

	my $subs = {
		base_url => sub { q{ /html/head/base } },
		heads    => sub { xpath_heads() },
		js       => sub { q{ //script } },
		img      => sub { q{ //img } },
		css => sub { 
			q{ 
				//node()[ 
					( self::link and ( @rel = "stylesheet" ) )
						or
					( self::style )
				]
			}
		}, 
		nodes_between_two_comments => sub {
			q{ 
				//node()
					[	( 	preceding-sibling::comment()[. = '_BEGIN_']
								and
							following-sibling::comment()[. = '_END_'] 
						) 
							or 
						( self::comment()[ . = '_BEGIN_' ] )
							or 
						( self::comment()[ . = '_END_' ] )
					]
			}
		},
		codepage => sub {
			q{
    			//meta[ ( @http-equiv and @content ) or (@charset) ]
			}
		}
	};
	
	my $s = $subs->{$id} || sub { "" };
	
	my $xpath = $s->();
	my $keys = [ keys %$subs ];
	
	while(my($k,$v) = each %{$repl}){
		$xpath =~ s/$k/$v/g;
	}
	return wantarray ? ($xpath) : $xpath;
}

sub xp_ids {
	my @k;
	
	push @k, 
		qw( js img css ),
		qw( heads ),
		qw( base_url ),
		qw( codepage ),
		qw( nodes_between_two_comments ),
		;

	return @k;
}

1;
