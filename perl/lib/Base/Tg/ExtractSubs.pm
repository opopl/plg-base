package Base::Tg::ExtractSubs;

use strict;
use warnings;

#https://gist.github.com/mfontani/1533835#
#
use common::sense;
use PPI;

our $FILE;
our @LINES;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
	$FILE
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw(
	@LINES
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

our @EXPORT  = qw( );

our $VERSION = '0.01';

sub main() {
	my $doc = PPI::Document->new($FILE);
	
	$doc->prune('PPI::Token::Whitespace');
	$doc->prune('PPI::Token::Comment');
	$doc->prune('PPI::Token::Pod');
	
	# Find all the *named* subroutines
	my $sub_nodes = $doc->find(sub {
	    $_[ 1 ]->isa('PPI::Statement::Sub') and $_[ 1 ]->name
	});

	for my $sub ( @$sub_nodes ) {
	
	    # Find all variable declarations inside the subroutine
	    my $var_decls = $sub->find(sub {
	        $_[ 1 ]->isa('PPI::Statement::Variable') and $_[ 1 ]->variables
	    });
	
	    # keep only vars which get assigned "shift" or @_
	    my @vars;
	    for my $var (@$var_decls) {
	        push @vars, $var
	            if _is_sub_var_decl($var);
	    }
	
	    # Print the "prototype" for the sub
	    push @LINES,
	        "Sub ", $sub->name, " ", $sub->prototype, " ( ",
	        join(', ', map {$_->variables} @vars),
	        " )\n";
	
	}

}

sub _is_sub_var_decl {
    my ($var) = @_;

    # PPI::Statement::Variable
    #   PPI::Token::Word          'my'
    #   PPI::Token::Symbol        '$class'
    #   PPI::Token::Operator      '='
    #   PPI::Token::Word          'shift'
    #   PPI::Token::Structure     ';'

    # PPI::Statement::Variable
    #   PPI::Token::Word          'my'
    #   PPI::Structure::List      ( ... )
    #     PPI::Statement::Expression
    #       PPI::Token::Symbol        '$self'
    #       PPI::Token::Operator      ','
    #       PPI::Token::Symbol        '$subname'
    #   PPI::Token::Operator      '='
    #   PPI::Token::Magic         '@_'
    #   PPI::Token::Structure     ';'

    my $variables = [ $var->find(sub {
        ($_[1]->isa('PPI::Token::Word') && $_[1]->content eq 'shift') ||
        ($_[1]->isa('PPI::Token::Magic') && $_[1]->content eq '@_')
    }) ] ;
	return scalar @$variables;
}
 
1;
