
package Base::Tg::Knutov;

use warnings;
use strict;

use 5.010;
use PPI;


our $FILE;
our @LINES;


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


=head1 SYNOPSIS

	Base::Tg::Knutov::main();

	$Base::Tg::Knutov::FILE = $file;
	my @lines  = @Base::Tg::Knutov::LINES;

=cut

my %variables;
my %scheduled;
my %subs;

=head1 METHODS

=cut

sub main {

	my $doc    = PPI::Document->new($FILE);

	my @tokens = $doc->children;
	foreach my $token ( @tokens )
	{
	    given ( $token->class )
	    {
	        process_statement( $token ) when 'PPI::Statement';
	        process_variable( $token ) when 'PPI::Statement::Variable';
	        process_sub( $token ) when 'PPI::Statement::Sub';
	        process_scheduled( $token ) when 'PPI::Statement::Scheduled';
	    }
	}
	
	print_names( \%variables, 'v' );
	print_names( \%subs,      'f' );
	print_names( \%scheduled, 'p' );
}

# ------------------------------------------------------------------------------
sub add_name
	{
	    my ( $list, $token, $content ) = @_;
	    # $content здесь на всякий случай, мало ли захочется где-то, потом,  получить полную строку
	    my $name = $token->content;
	    $list->{$name} = () unless exists $list->{$name};
	    $list->{$name}->{ $token->line_number } = $content;
	}

# ------------------------------------------------------------------------------
	sub print_names
	{
	    my ( $list, $type ) = @_;
	
	    foreach my $name (
	        sort {
	            my $an = $a =~ /^[\$\%\@](.+)$/ ? $1 : $a;
	            my $bn = $b =~ /^[\$\%\@](.+)$/ ? $1 : $b;
	            lc $an cmp lc $bn;
	        } keys $list )
	    {
	        foreach my $line ( sort { $a <=> $b } keys $list->{$name} )
	        {
	            push @LINES, "$name:$line\t$FILE\t$line;\"\t$type";
	        }
	    }
	}

# ------------------------------------------------------------------------------
# @EXPORT = qw(aaa), @EXPORT_OK = qw(bbb);
# ------------------------------------------------------------------------------
sub process_statement
{
    my ( $tok ) = @_;

    my @tokens = $tok->children;
    return unless $#tokens > 0;
    foreach my $token ( @tokens )
    {
        add_name( \%variables, $token, $tok->content )
          if $token->class eq 'PPI::Token::Symbol';
    }
}

# ------------------------------------------------------------------------------
# sub aaa($$$);
# sub aaa{};
# ------------------------------------------------------------------------------
sub process_sub
{
    my ( $tok ) = @_;

    my @tokens = $tok->children;
    return unless $#tokens > 1;
    shift @tokens;
    foreach my $token ( @tokens )
    {
        next
          if $token->class eq 'PPI::Token::Whitespace'
          or $token->class eq 'PPI::Token::Comment'
          or $token->class eq 'PPI::Token::Pod';
        # первый значащий токен после 'sub' должен быть PPI::Token::Word:
        return unless $token->class eq 'PPI::Token::Word';
        add_name( \%subs, $token, $tok->content );
        last;
    }
}

# ------------------------------------------------------------------------------
# my $aaa;
# our ($aaa, $bbb);
# ------------------------------------------------------------------------------
sub process_variable
{
    my ( $tok ) = @_;

    my @tokens = $tok->children;
    foreach my $token ( @tokens )
    {
        # список или выражение - ищем имена рекурсивно:
        process_variable( $token ), next if $token->class eq 'PPI::Structure::List';
        process_variable( $token ), next if $token->class eq 'PPI::Statement::Expression';
        add_name( \%variables, $token, $tok->content )
          if $token->class eq 'PPI::Token::Symbol';
    }
}

# ------------------------------------------------------------------------------
# BEGIN {}; CHECK, UNITCHECK, INIT, END
# ------------------------------------------------------------------------------
sub process_scheduled
{
    my ( $tok ) = @_;

    my @tokens = $tok->children;
    return unless $#tokens > 0;
    add_name( \%scheduled, $tokens[0], $tok->content );
}

1;
