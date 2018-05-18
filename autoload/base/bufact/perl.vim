
function! base#bufact#perl#pod_process ()
	call base#buf#start()
perl << eof
	use Vim::Perl qw(:funcs :vars);
	$Vim::Perl::CURBUF=$curbuf;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	package PP;

	use Data::Dumper;
	use Vim::Perl qw(:funcs :vars);

	use base qw(Pod::Simple::PullParser);

	sub run {
    	my $self = shift;
			my (@tokens, $title);
	
			while (my $token = $self->get_token) {
	        push @tokens, $token;
	
	        # We're looking for a "=head1 NAME" section
#	        if (@tokens > 5) {
#	            if ($tokens[0]->is_start && $tokens[0]->tagname eq 'head1' &&
#	                $tokens[1]->is_text && $tokens[1]->text =~ /^name$/i &&
#	                $tokens[4]->is_text)
#	            {
#	                $title = $tokens[4]->text;
#	                # We have the title, so we can ignore the remaining tokens
#	                last;
#	            }
#	
#	            shift @tokens;
#	        }
	    }
			VimMsg(Dumper(\@tokens));
	
	    # No title means no POD -- we're done with this file
	    return if !$title;
	
	}
	package main;

	my $pp = PP->new;
	$pp->set_source($lines);
	$pp->run;

eof
endf

function! base#bufact#perl#ppi_vars ()
	call base#buf#start()
	let file = b:file
	let vars = []

	let lines_tags=[]
perl << eof
	use PPI;
	use Data::Dumper;

	use Vim::Perl qw(:funcs :vars);
	use Base::PerlFile;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	$Vim::Perl::CURBUF = $curbuf;

	my $file = VimVar('file');
 	my $DOC = PPI::Document->new($file);
	$DOC->index_locations;

	my $f = sub { $_[1]->isa( 'PPI::Statement::Variable' ) };
	my @v = @{ $DOC->find( $f ) || [] };
eof
	call base#buf#open_split({ 'lines' : lines_tags })
endf

function! base#bufact#perl#knutov ()
	call base#buf#start()
	let file = b:file
	
	let LINES=[]
perl << eof
	use 5.010;
	use strict;
	use PPI;
	
	my %variables;
	my %scheduled;
	my %subs;

	my $file = VimVar('file');
	my @LINES;

	my $doc    = PPI::Document->new( $file);

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
	            push @LINES, "$name:$line\t$file\t$line;\"\t$type";
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

	VimListExtend('LINES',[@LINES]);
eof
	call base#buf#open_split({ 'lines' : LINES })

endfunction

function! base#bufact#perl#ppi_list_subs ()
	call base#buf#start()
	let file = b:file
	let subnames = []

	let lines_tags=[]
perl << eof
	use PPI;
	use Data::Dumper;

	use Vim::Perl qw(:funcs :vars);
	use Base::PerlFile;

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

	$Vim::Perl::CURBUF = $curbuf;

	my $file = VimVar('file');
	my $pf = Base::PerlFile->new;
	$pf->ppi_list_subs({ file => $file });

	VimListExtend('lines_tags',$pf->{lines_tags});
	VimListExtend('subnames',$pf->{subnames});
eof
	"call base#buf#open_split({ 'lines' : subs })
	call base#buf#open_split({ 'lines' : lines_tags })
endf

"htmllines	/home/mmedevel/repos/git/htmltool/lib/HTML/Work.pm	/^sub htmllines {$/;"	s
