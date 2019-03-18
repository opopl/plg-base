
package Save::VH::Docs::php_net;

use strict;
use warnings;
use utf8;

###use
use Data::Dumper qw(Dumper);
use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath rmtree);
use File::Basename qw(dirname basename);
use File::Slurp qw(read_file write_file);
use File::Copy qw(copy move);
use FindBin qw($Script $Bin);
use HTML::Work;

use File::Find qw(find);

my @files;
my @exts = qw(html htm);
my @dirs;

use base qw(Save::VH::Docs);

our ($html_dir,$topic);

$html_dir = 'c:/saved/html/php_net/';
$topic = '';

sub run {
	my ($self,$ref) = @_;

	$ref->{code_filename} = sub {
		s/[\/-]/_/g;
		s/\.(\w*)$//g;
		s/^mod_//g;
	};

	$ref->{dir} = $html_dir;

	# where to save VimHelp files
	$ref->{vhdir} = catfile($ENV{plg},qw(idephp help php ),$topic);

	$ref->{tagsub} = sub { 
		local $_ = shift; 
		return 'httpd_'.$_ 
	};

	$self->SUPER::run($ref);

}

1;
