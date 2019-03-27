package Base::Pod;

use strict;
use warnings;

use Data::Dumper;

use base qw(Pod::Simple::PullParser);

sub run {
	my $self = shift;

	my (@tokens, $title);
	
	while (my $token = $self->get_token) {
    	push @tokens, $token;

		print $token->dump . "\n";

        # We're looking for a "=head1 NAME" section
        if (@tokens > 5) {
            if ($tokens[0]->is_start && $tokens[0]->tagname eq 'head1' &&
                $tokens[1]->is_text && $tokens[1]->text =~ /^name$/i &&
                $tokens[4]->is_text)
            {
                $title = $tokens[4]->text;
                # We have the title, so we can ignore the remaining tokens
                last;
            }

            shift @tokens;
    	}
	}
		#VimMsg(Dumper(\@tokens));

    # No title means no POD -- we're done with this file
    return if !$title;
	
}

#        $DEBUG and print STDERR "Token: ", $token->dump, "\n";
        #if($token->is_start) {
          #...access $token->tagname, $token->attr, etc...

        #} elsif($token->is_text) {
          #...access $token->text, $token->text_r, etc...

        #} elsif($token->is_end) {
          #...access $token->tagname...

        #}


1;
 

