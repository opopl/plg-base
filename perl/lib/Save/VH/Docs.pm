
package Save::VH::Docs;

use strict;
use warnings;
use utf8;

###use
use Data::Dumper qw(Dumper);
use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath);
use File::Basename qw(basename);

use HTML::Work;

use File::Find qw(find);

my @files;
my @exts=qw(html htm);

=head1 NAME

Save::VH::Docs - vimhelp converter from HTML files

=head1 METHODS

=cut

=head2 run

=head3 Usage

	my $sv = Base::VH::Docs->new;

	my $ref = {
		# input directory with html files
		dir => $dir,

		# callback which returns vimhelp tag to be
		# 	store as *tag* inside the generated vimhelp file 
		mytag => sub { ... },

		code_filename => sub { ... },
	 
		# where to store vimhelp files
		vhdir => $vhdir,
	};

	$sv->run($ref);

=cut

sub run {
	my ($self,$ref) = @_;

	my $dir    = $ref->{dir} || '';
	my $mytag = $ref->{mytag} || sub { my $file = shift; basename($file); };

	my $code_filename = $ref->{code_filename} || sub {};

	my $vhdir = $ref->{vhdir} || '';

	return unless $vhdir;
	mkpath $vhdir unless -d $vhdir;

	my($actions,$xpath_rm,$xpath_cb);

	$actions  = $ref->{actions} || [qw(replace_a replace_pre)];
	$xpath_rm = $ref->{xpath_rm} || undef;
	$xpath_cb = $ref->{xpath_cb} || [ ];

	find({ 
		wanted => sub { 
			foreach my $ext (@exts) {
				if (/\.$ext$/) {
					push @files,$File::Find::name;
				}
			}
			 
		} 
	},$dir
	);

	my $htw = HTML::Work->new;
	
	foreach my $file (@files) {
		local $_ = basename( $file );

		$code_filename->();
	
		print $_ . "\n";
	
		my ($in_html,$out_vh,$tag);

		$tag      = $mytag->($_);
		
		$in_html  = $file;
		$out_vh   = catfile($vhdir,$_ . '.txt');

	
		push @$xpath_cb, { 
			'xpath' => '//pre[@class="code"]', 
			cb => sub { 
				my $n = shift; 
				my $code = $n->textContent;
			},
		};
	
		#next if -e $out_vh;
		
		my $vhref={
			# input HTML file
			in_html => $in_html,
			# output VimHelp file
			out_vh  => $out_vh,
			# head Vim tag (to be enclosed as *TAG* at the top of the outcome VimHelp file )
			tag 	=> $tag,
			# possible additional actions, may include
			# 	replace_a - replace all links with text
			actions => $actions || [],
			# xpath to select elements to be removed
			xpath_rm => $xpath_rm || [],
			# xpath callbacks
			xpath_cb => $xpath_cb || [],
		};
		
		$htw->save_to_vh($vhref);
	
	}

}

1;
