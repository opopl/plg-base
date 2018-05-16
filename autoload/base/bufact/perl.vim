
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

function! base#bufact#perl#ppi_list_subs ()
	call base#buf#start()
	let file = b:file
	let subs = []

	let lines_tags=[]
perl << eof
	use PPI;
	use Data::Dumper;

	use Vim::Perl qw(:funcs :vars);
	$Vim::Perl::CURBUF = $curbuf;

	my $file = VimVar('file');

	my $lines = [ $curbuf->Get(1 .. $curbuf->Count) ];

  my $DOC = PPI::Document->new($file);
	$DOC->index_locations;

	my $f = sub { $_[1]->isa( 'PPI::Statement::Sub' ) || $_[1]->isa( 'PPI::Statement::Package' ) };
	my @packs_and_subs = @{ $DOC->find( $f ) };

	my $ns;
	for my $node (@packs_and_subs){
		$node->isa( 'PPI::Statement::Sub' ) && do { 
				push @subs, { 
						'fullname' => $ns.'::'.$node->name, 
						'name'     => $node->name,
				} };
		$node->isa( 'PPI::Statement::Package' ) && do { $ns = $node->namespace; };
	}
	VimListExtend('subs',[ map { $_->fullname} @subs ]);

	my @lines_tags;
	foreach my $sub (@subs) {
		my @ta = ($sub, $file, '/^sub' )
	}
eof
	call base#buf#open_split({ 'lines' : subs })
endf

"htmllines	/home/mmedevel/repos/git/htmltool/lib/HTML/Work.pm	/^sub htmllines {$/;"	s
