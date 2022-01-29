
package Base::XML;

=head1 NAME

Base::XML -- module for working with XML

=head1 SYNOPSIS

    use Base::XML qw(:funcs :vars);

=head1 EXPORTS

=head1 METHODS

=cut

use strict;
use warnings;

use HTML::Entities;

use XML::LibXML;
use XML::LibXML::PrettyPrint;

use Base::Arg qw(hash_update);
use Base::String qw(
    str_split
    str_sum
);
use String::Util qw(trim);

use Data::Dumper;
use XML::Hash::LX qw(xml2hash);

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
    xml_pretty
    pl_to_xml
    xml_to_pl

    dom_new
    parser_new
    opts_str_sum

    node_cdata2text
    node_to_pl
    node_trim
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

local $|=1;

sub dom_new {
    my ($ref) = @_;

    $ref ||= {};
    my $root_name = $ref->{root_name} || 'root';

    my $parser = parser_new();
    my $dom    = XML::LibXML::Document->new( "1.0", "UTF-8" );

    if ($root_name) {
        my $root = $dom->createElement( $root_name );
        $dom->setDocumentElement( $root );
    }

    
    return ($dom, $parser);
}

sub parser_new {
    my (@o) = @_;

    my $defs = {
        expand_entities => 0,
        load_ext_dtd    => 1,
        no_blanks       => 1,
        no_cdata        => 1,
        line_numbers    => 1,
    };
    unshift @o, %{ $PARSER_OPTS || $defs };

    my $parser = XML::LibXML->new(@o);
    return $parser;
}


sub xml_pretty {
    my ($xml,%opts) = @_;

    my ($xml_pp, $dom);

    my ($ids, $xpath_ids);
    $ids ||= $opts{ids} || [];


    if (@$ids) {
        $xpath_ids = q{ //*[ } 
            . join (' or ', map { qq{name()='$_'}} @$ids) . q{ ] };
    }

    $dom = $xml if ref $xml;
    eval { 
        $dom ||= XML::LibXML->load_xml(
            string          => $xml,
            recover         => 1,
            suppress_errors => 1,
        );
        my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");

        my %vals;
        if ($xpath_ids) {
	        $dom->findnodes($xpath_ids)
	            ->map(
	                sub{
	                    my($n)=@_;
	                    
	                    my $ind = " " x 5;
	                    my $xp =  $n->nodePath();
	                    my $keep = $n->to_literal;
	                    $keep =~ s/^\s*/$ind/gms;
	                    $vals{$xp} = $keep;
	                }
	            );
        }

        $pp->pretty_print($dom); 

        foreach my $xp (keys %vals) {
            my $kept = $vals{$xp}; 
        
            foreach my $n ($dom->findnodes($xp)){
                $n->removeChildNodes();
                $n->appendText("\n");
                $n->appendText($kept);
                $n->appendText("\n");
            }
        }
        local $XML::LibXML::skipXMLDeclaration = 0;
        $xml_pp =  $dom->toString;
        my @pp_lines = split("\n" => $xml_pp);

        my (@xp, $xp);
        my %inds;
        foreach(@pp_lines) {
            /^(?<ind>\s*)<(?<tag>\w+)>\s*$/ && do {
                my $t   = $+{tag};
                my $ind = $+{ind};

                push @xp, $t;
                $xp = join(" ",@xp);

                $inds{$xp} = $ind;

                next;
            };
            /^\s*<\/(\w+)>/ && do {
                $xp = join(" ",@xp);
                my $t = pop @xp;
                my $ind = $inds{$xp} || '';

                s/^\s*/$ind/g;

                next;
            };
        }
        $xml_pp = join("\n",@pp_lines);
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
    #   of the input Perl data will be inserted
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
        attr   => $ref->{attr},
    };

    my $key_is_attr = sub {
        my ($key) = @_;
        grep { /^$key$/ } @{ $ref->{attr} || []};
    };

    my @vnodes;
    if (ref $data eq "ARRAY"){

        foreach my $v (@$data) {

            my $vnode = $dom->createElement( $listas );

            hash_update($o,{ key => undef, parent => $vnode });
            my ($xml, $cnodes) = pl_to_xml($v, $o);

            $vnode->appendChild($_) for(@$cnodes);

            push @vnodes, $vnode;
            $vnode = $parent->appendChild($vnode);
        }
        
    }elsif( ref $data eq "HASH" ){

        while( my($k, $v) = each %{$data} ){
            my $vnode;
            
            if (not $key_is_attr->($k)) {
                $vnode = $dom->createElement( $k );
            }

            hash_update($o, { key => $k });

            my ($xml, $cnodes) = pl_to_xml($v, $o);

            if ($vnode) {
                push @vnodes, $vnode;
                if (@$cnodes) {
                    $vnode->appendChild($_) for(@$cnodes);
                    $vnode = $parent->appendChild($vnode) ;
                }
            }

   #         print Dumper($xml);

        }


    }elsif(ref $data eq ""){

        my $vnode;
        if ( $key && $key_is_attr->($key) ) { 
            $parent->setAttribute( $key => $data );
        }else{
            $vnode = $dom->createTextNode( $data );
        }

        push @vnodes, $vnode if $vnode;  

    }

    push @res, [@vnodes];

    $xmlout = $parent->toString(2);
    #$xmlout = xml_pretty($xmlout);

    unshift @res,$xmlout;

    return @res;

    #my $xml = join("\n",map { $_->toString} @knodes );


}

=head2 xml_to_pl

=head3 Usage

    node_to_pl(
        node => $node,

        # nodes which should be converted 
        #   to elements of a perl list
        listas => 'item',

        listall => 1,
    );

    node_to_pl(
        node => $node,

        listall => 1,
    );

=head3 Purpose

=cut

sub node_to_pl {
    my ($ref) = @_;

    my $node = $ref->{node};

    my @listas = str_split($ref->{listas});

    print 'node_to_pl' . "\n";
    print Dumper({ %$ref, node => $node->nodeName }) . "\n";

    my $n_is_list = sub {
        my ($a) = @_;
        my $is = 
            $ref->{listall} ? 1 : 
            ( grep { /^$a$/ } @listas ? 1 : 0 );
        return $is;
    };

    my $p = {};
    $p->{node} = $node->parentNode;

    if ($p->{node}) {
        $p->{name} = $p->{node}->nodeName;
        $p->{type} = $p->{node}->nodeType;
    }

    my $name = $node->nodeName;
    my $type = $node->nodeType;

    my $is_list = $n_is_list->($name);

    my ($data, $v);
    if ( $type == XML_ELEMENT_NODE ) {
        $data = ($is_list) ? [] : {};

    } elsif ( $type == XML_TEXT_NODE ){
        $data = $node->textContent;
    }

    my @cnodes = $node->childNodes;
    print Dumper([ map { $_->nodeName} @cnodes ]);

    my $is_text = ( ! grep { $_->nodeType != XML_TEXT_NODE } @cnodes ) ? 1 : 0;
    if($is_text){
        $data    = '';
        $is_list = 0;
    }

    my $has={};
    foreach my $cn (@cnodes) {
        my ($cname, $ctype) = ( $cn->nodeName, $cn->nodeType );

        my $cdata = node_to_pl({ 
            %$ref,
            node => $cn 
        });

        if ($ctype == XML_TEXT_NODE) {
            $data = $cdata;
            next;
        }

        if ($is_list) {
            print Dumper($data) . "\n";
            push @$data, $cdata;

        }else{
            unless ($has->{$cname}) {
                $data->{$cname} = $cdata;
            }else{
                if (ref $data eq 'HASH') {
                    my $v = $data->{$cname};
                    $data = [$v];
                }elsif(ref $data eq 'ARRAY'){
                    push @{$data}, $cdata;
                }
            }
        }

        $has->{$cname} = 1;

    }

    return $data;
}

sub node_trim {
    my ($n) = @_;

    my $t = $n->to_literal;
    $t = trim($t);
    $n->removeChildNodes;
    $n->appendText($t);
}

sub xml_to_pl {
    my ($xml) = @_;

    my $dom = XML::LibXML->load_xml(
        string => $xml,
    );
    my $data = node_to_pl({ 
        node       => $dom,
        list_items => 'item'
    });
    return $data;
}

our $X2A = 0;
our %X2A = ();

our %X2H = (
    order  => 0,
    attr   => '-',
    text   => '#text',
    join   => '',
    trim   => 1,
    cdata  => undef,
    comm   => undef,
    #cdata  => '#',
    #comm   => '//',
);

sub _x2h {
    my ($doc) = @_;
    my $res;

        if ($doc->hasChildNodes or $doc->hasAttributes) {

            if ($X2H{order}) {
                $res = [];
                my $attr = {};
                for ($doc->attributes) {
                    #warn " .> ".$_->nodeName.'='.$_->getValue;
                    $attr->{ $X2H{attr} . $_->nodeName } = $_->getValue;
                }
                push @$res, $attr if %$attr;
            } else {
                $res = {};
                for ($doc->attributes) {
                    #warn " .> ".$_->nodeName.'='.$_->getValue;
                    $res->{ $X2H{attr} . $_->nodeName } = $_->getValue;
                }
            }

            for my $child_node ($doc->childNodes) {
                local $_ = $child_node; 

                my $child_ref = ref $child_node;
                my $nn;
                if ($child_ref eq 'XML::LibXML::Text') {
                    $nn = $X2H{text}
                }
                elsif ($child_ref eq 'XML::LibXML::CDATASection') {
                    $nn = defined $X2H{cdata} ? $X2H{cdata} : $X2H{text};
                }
                elsif ($child_ref eq 'XML::LibXML::Comment') {
                    $nn = defined $X2H{comm} ? $X2H{comm} : next;
                }
                else {
                    $nn = $child_node->nodeName;
                }
                my $child_data = _x2h($child_node);
                if ($X2H{order}) {
                    if ($nn eq $X2H{text}) {
                        push @{ $res }, $child_data if length $child_data;
                    } else {
                        push @{ $res }, { $nn => $child_data };
                    }
                } else {
                    if (( $X2A or $X2A{$nn} ) and !$res->{$nn}) { $res->{$nn} = [] }
                    if (exists $res->{$nn} ) {
                        #warn "Append to $res->{$nn}: $nn $child_data";
                        $res->{$nn} = [ $res->{$nn} ] unless ref $res->{$nn} eq 'ARRAY';
                        push @{$res->{$nn}}, $child_data if defined $child_data;
                    } else {
                        if ($nn eq $X2H{text}) {
                            $res->{$nn} = $child_data if length $child_data;
                        } else {
                            $res->{$nn} = $child_data;
                        }
                    }
                }
            }
            if($X2H{order}) {
                #warn "Ordered mode, have res with ".(0+@$res)." children = @$res";
                return $res->[0] if @$res == 1;
            } else {
                if (defined $X2H{join} and exists $res->{ $X2H{text} } and ref $res->{ $X2H{text} }) {
                    $res->{ $X2H{text} } = join $X2H{join}, grep length, @{ $res->{ $X2H{text} } };
                }
                delete $res->{ $X2H{text} } if $X2H{trim} and keys %$res > 1 and exists $res->{ $X2H{text} } and !length $res->{ $X2H{text} };
                return $res->{ $X2H{text} } if keys %$res == 1 and exists $res->{ $X2H{text} };
            }
        }
        else {
            $res = $doc->textContent;
            if ($X2H{trim}) {
                $res =~ s{^\s+}{}s;
                $res =~ s{\s+$}{}s;
            }
        }
    $res;
    
}

sub opts_str_sum {
    my ($obj, $nodes, $opts) = @_;
    $opts ||= [];
    $nodes ||= [];

    for my $opt (@$opts){
        foreach my $node (@$nodes) {
            $node
                ->findnodes(qq{./$opt/*})
                ->map( 
                    sub { 
                        my ($n) = @_;
                        my $h = xml2hash($n);

                        while(my($k,$v) = each %{$h}){
                            if (ref $v eq '') {
                                # old values already stored in $obj
                                my $vv  = $obj->{$opt}->{$k} || '';

                                # sum with the new values stored in $h
                                my $sum = str_sum( $vv, $v );

                                # reset $obj values
                                $obj->{$opt}->{$k} = $sum;
                            }
                        }

                    }
                );
        }
    }
}

1;
 

