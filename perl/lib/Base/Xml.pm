
package Base::XML;

use strict;
use warnings;

use HTML::Entities;

use XML::LibXML;
use XML::LibXML::PrettyPrint;

use Base::Arg qw(hash_update);

use Data::Dumper;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
	$PARSER $PARSER_OPTS
	$DOM $DOMCACHE 
	$XPATHCACHE
);
###export_vars_hash
my @ex_vars_hash=qw(
	%nodetypes
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
	node_cdata2text
	xml_pretty
	pl_to_xml

	dom_new
	parser_new
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

use vars qw( 
	$PARSER $PARSER_OPTS
	$DOM $DOMCACHE 
	$XPATHCACHE 
	%nodetypes 
);

# XML::LibXML exported constants
%nodetypes = reverse (
    XML_ELEMENT_NODE            => 1,
    XML_ATTRIBUTE_NODE          => 2,
    XML_TEXT_NODE               => 3,
    XML_CDATA_SECTION_NODE      => 4,
    XML_ENTITY_REF_NODE         => 5,
    XML_ENTITY_NODE             => 6,
    XML_PI_NODE                 => 7,
    XML_COMMENT_NODE            => 8,
    XML_DOCUMENT_NODE           => 9,
    XML_DOCUMENT_TYPE_NODE      => 10,
    XML_DOCUMENT_FRAG_NODE      => 11,
    XML_NOTATION_NODE           => 12,
    XML_HTML_DOCUMENT_NODE      => 13,
    XML_DTD_NODE                => 14,
    XML_ELEMENT_DECL            => 15,
    XML_ATTRIBUTE_DECL          => 16,
    XML_ENTITY_DECL             => 17,
    XML_NAMESPACE_DECL          => 18,
    XML_XINCLUDE_START          => 19,
    XML_XINCLUDE_END            => 20,
);

sub dom_new {
	my $parser = parser_new();
	my $dom    = $parser->createDocument( "1.0", "UTF-8" );
	
	return ($dom, $parser);
}

sub parser_new {
	my (@o) = @_;

	my $defs = {
		expand_entities => 0,
		load_ext_dtd    => 1,
		no_blanks       => 0,
		no_cdata        => 1,
		line_numbers    => 1,
	};
	unshift @o, %{ $PARSER_OPTS || $defs };

	my $parser = XML::LibXML->new(@o);
	return $parser;
}


sub xml_pretty {
	my ($xml) = @_;

	my $xml_pp;
	eval { 
		my $dom = XML::LibXML->load_xml(
			string          => $xml,
			recover         => 1,
			suppress_errors => 1,
		);
		my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
		$pp->pretty_print($dom); # modified in-place
		$xml_pp =  $dom->toString;
	};
	$xml = $xml_pp if $xml_pp;

	return $xml;

}

=head2 pl_to_xml

=head3 Usage

	my $xml = pl_to_xml(
		# XML::LibXML DOM instance
		dom => $dom,

		# parent node, (XML::LibXML::Node instance)
		parent => $parent,

		key => $key,

		# default is 'item'
		listas => 'item',
	);

=head3 Purpose

=cut

sub pl_to_xml {
	my ($data,$ref) = @_;

	$ref ||= {};

	my $anew;
	$anew = 1 unless $ref->{dom};

	my $listas = $ref->{listas} || 'item';

	my ($dom, $parser) = dom_new();
	
	$dom = $ref->{dom} if $ref->{dom};

	# parent node into which the DOM representation
	# 	of the input Perl data will be inserted
	my $parent = $ref->{parent};

	if ($anew) {
	    my $root = $dom->createElement( 'root' );
		$dom->setDocumentElement( $root );

		$parent = $dom->documentElement;
	}

	my $key = $ref->{key} || '';

	my $xmlout;
	my @res;

	my $o = {
		dom    => $dom,
		parent => $parent,
		key    => $key,
	};

	my @vnodes;
	if (ref $data eq "ARRAY"){

		foreach my $v (@$data) {

	    	my $vnode = $dom->createElement( $listas );

			hash_update($o,{key => undef });
			my ($xml, $cnodes) = pl_to_xml($v, $o);

			$vnode->appendChild($_) for(@$cnodes);

			push @vnodes, $vnode;
			$vnode = $parent->appendChild($vnode);
		}
		$xmlout = $parent->toString;
		
	}elsif( ref $data eq "HASH" ){

		while( my($k, $v) = each %{$data} ){
	    	my $vnode = $dom->createElement( $k );

			push @vnodes, $vnode;

			hash_update($o,{
				key    => $k,
			});
			my ($xml, $cnodes) = pl_to_xml($v, $o);

			if (@$cnodes) {
				$vnode->appendChild($_) for(@$cnodes);
				$vnode = $parent->appendChild($vnode);
			}

   #         print Dumper($xml);

		}

		#$xmlout = join("\n", map { $_->toString } @knodes );
		$xmlout = $parent->toString;

	}elsif(ref $data eq ""){

		if ($key) {
			$parent->setAttribute( $key => $data );
		}else{
	    	my $vnode = $dom->createTextNode( $data );
			push @vnodes, $vnode;
		}

		$xmlout = $parent->toString;

	}

	push @res, [@vnodes];
	$xmlout = xml_pretty($xmlout);

	unshift @res,$xmlout;

	return @res;

	#my $xml = join("\n",map { $_->toString} @knodes );


}


1;
