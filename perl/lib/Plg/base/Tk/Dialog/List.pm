
package Plg::Base::Tk::Dialog::List;

use strict;
use warnings;

use Data::Dumper qw(Dumper);
use Tk;

use FindBin qw($Bin $Script);
use lib "$Bin/../perl/lib";

use Base::Arg qw(
	hash_inject
);

use base qw(Plg::Base::Tk::Dialog);

sub init {
	my $self = shift;

	$self->SUPER::init();

	my $h = { };
	hash_inject($self, $h);
		
	return $self;
}

1;
 

