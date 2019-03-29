
package Base::Config;

use strict;
use warnings;

use Data::Dumper qw(Dumper);
use FindBin qw($Bin $Script);

use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catfile);

use XML::LibXML::Simple;

our ($CONFIG, $DOM_CONFIG, $HEADTAG);

sub config_get_hash {
	my ($ref) = @_;

	my $xpath = $ref->{xpath} || '';
	my %opts  = @_;

	my $hash  = {};
	my $order = [];

	my @nodes = config_get_nodes({ xpath => $xpath });

	my $xml = config_get_xml({ xpath => $xpath });

	my $cb_key=$opts{cb_key} || undef;
	foreach my $n (@nodes) {
		my @sn=$n->findnodes('./*');
		foreach my $sn (@sn) {
			my $value = $sn->textContent;
			my $key   = $sn->nodeName;

			push @$order,$key;

			if ($cb_key && ref $cb_key eq 'CODE') {
				$key = $cb_key->($key);
			}
			
			$hash->{$key}=$value;
		}

	}

	return ($hash,$order);
}

sub config_get_text {
	my ($ref)  = @_;

	my $xpath = $ref->{xpath} || '';

	my @nodes = config_get_nodes({ xpath => $xpath });

	my @values;
	foreach my $n (@nodes) {
		push @values,$n->textContent;
		#push @values,$n->toString;
	}
	wantarray ? @values : \@values;

}


sub config_dump {
	my ($ref) = @_;

	my $xpath = $ref->{xpath} || '';

	my $xml = config_get_xml({ xpath => $xpath });

	print Dumper($xml);

}

=head2 config_get_xml 

=over

=item Usage

	my $xpath = '//...';
	my $xml   = $app->config_get_xml($xpath);

=back

=cut

sub config_get_xml {
	my ($ref) = @_;

	my $xpath = $ref->{xpath} || '';
	my @nodes = config_get_nodes({ xpath => $xpath });

	my @values;
	foreach my $n (@nodes) {
		push @values,$n->toString;
	}
	my $xml = join("\n",@values);

	return $xml;
}


sub init_config {
	my ($ref) = @_;

	my $bname = basename($Script);
	my $root  = $bname;

	$root=~s/\.(\w)$//g;

	my $file_xml = catfile($Bin, 'config.xml');

	unless(-e $file_xml){ return; }

	my @out;
	open(F,"<$file_xml") || die $!;
	while(<F>){
		chomp;
		my $line = $_;
		push @out,$line;
	}
	close(F);

	my $xml = join("\n",@out);

	my $doc;	
    
	eval { $doc = XML::LibXML->load_xml(string => $xml);  };
	if ($@) {
		my @err; 
		
		push @err,  
			'Failure to process XML contents from file:',$file_xml,
			'Error message:',$@,
			;

		log(@err);
	}
	
	my $headtag = "htmltool";

	my @nodes   = $doc->findnodes("/root/$headtag/*");
	my @l;
	foreach my $n (@nodes) {
		push @l, $n->toString;
	}
	my $xml_conf = join("\n",@l) ;
	$xml_conf = "<$headtag>".$xml_conf."</$headtag>";

    my $dom_conf = XML::LibXML->load_xml(
		string => $xml_conf
	);

	my $xs       = XML::LibXML::Simple->new;

	my $data = $xs->XMLin($xml_conf);

	$CONFIG     = $data;
	$DOM_CONFIG = $dom_conf;

}

sub config_get_attr {
	my ($ref) = @_;

	my ($xpath,$attr) = @{$ref}{qw( xpath attr )};

	my @nodes = config_get_nodes({ 
		xpath => $xpath 
	});

	my @list_attr;
	foreach my $node (@nodes) {
		push @list_attr, $node->getAttribute($attr);
	}

	wantarray ? @list_attr : \@list_attr;
}

sub config_get_nodes {
	my ($ref) = @_;

	my $xpath = $ref->{xpath} || '';

	my $headtag = $HEADTAG || 'root';

	$xpath = '/' . $headtag . $xpath;

	my $dom   = $DOM_CONFIG;
	my @nodes = $dom->findnodes($xpath);

	wantarray ? @nodes : \@nodes;

}

=head2 config_get_text_split

=head3 Usage
	
	config_get_text_split($xpath);
	config_get_text_split($xpath,$delim);

=head3 Purpose

=cut

sub config_get_text_split {
	my ($ref) = @_;

	my $xpath = $ref->{xpath} || '';
	my $delim = $ref->{delim} || ',';

	my @nodes = config_get_nodes({ 
		xpath => $xpath 
	});

	my @values;
	foreach my $n (@nodes) {
		push @values,( map { 
			s/^\s*//g; 
			s/\s*$//g; $_ }
		split($delim,$n->textContent));
	}
	wantarray ? @values : \@values;

}

1;
 
