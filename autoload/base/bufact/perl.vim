
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
	use Base::Tg::Knutov qw(@LINES $FILE);

	$FILE=VimVar('file');
	my @lines=@LINES;
	VimListExtend('LINES',[@lines]);
eof
	call base#buf#open_split({ 'lines' : LINES })

endfunction

function! base#bufact#perl#extract_subs ()
	call base#buf#start()
	let file = b:file
	let lines = []
perl << eof
	use Base::Tg::ExtractSubs qw($FILE @LINES);
	$FILE=VimVar('file');

	Base::Tg::ExtractSubs::main();

	VimListExtend('lines',[@LINES]);
eof
	call base#buf#open_split({ 'lines' : lines })
	
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
	call base#buf#open_split({ 'lines' : subnames })
endf

"htmllines	/home/mmedevel/repos/git/htmltool/lib/HTML/Work.pm	/^sub htmllines {$/;"	s
