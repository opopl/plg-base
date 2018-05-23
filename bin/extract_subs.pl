#!/usr/bin/env perl
#https://gist.github.com/mfontani/1533835#
#
use common::sense;
use PPI;

my $file = shift;
die "Need a file to operate on\n"
    if !$file
    || !-f $file;

my $doc = PPI::Document->new($file);

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
    print
        "Sub ", $sub->name, " ", $sub->prototype, " ( ",
        join(', ', map {$_->variables} @vars),
        " )\n";

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

    my $variables = $var->find(sub {
        ($_[1]->isa('PPI::Token::Word') && $_[1]->content eq 'shift') ||
        ($_[1]->isa('PPI::Token::Magic') && $_[1]->content eq '@_')
    });
return scalar @$variables;
}
