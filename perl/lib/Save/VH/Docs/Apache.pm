package Save::VH::Docs::Apache;

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
my @exts=qw(html htm);
my @dirs;

use base qw(Save::VH::Docs);

my $dir = 'c:/help/apache/httpd-docs-2.4.28.en';

sub run {
	my ($self,$ref) = @_;


	push @dirs,$dir;
	
	find({ 
		wanted => sub { 
			foreach my $ext (@exts) {
				if (/\.$ext$/) {
					push @files,$File::Find::name;
				}
			}
			 
		} 
	},@dirs
	);
	our $htw = HTML::Work->new;
	our $vhdir = catfile($ENV{plg},qw(idephp help apache httpd_docs ));
	mkpath $vhdir unless -d $vhdir;
	
	foreach my $file (@files) {

		local $_=$file;
		s/$dir\///g;
		s/[\/-]/_/g;
		s/\.(\w*)$//g;
		s/^mod_//g;
	
		print $_ . "\n";
		my $id = $_;
	
		my ($in_html,$out_vh,$tag,$actions,$xpath_rm,$xpath_cb);
		
		$in_html  = $file;
		$out_vh   = catfile($vhdir,$id . '.txt');
		$tag      = 'httpd_'.$id;
		$actions  = [qw(replace_a replace_pre)];
		$xpath_rm = undef;
		$xpath_cb = [ ];
	
		push @$xpath_cb, { 
			'xpath' => '//pre[@class="code"]', 
			cb => sub { 
				my $n=shift; 
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
