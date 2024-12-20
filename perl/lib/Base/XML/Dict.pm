
package Base::XML::Dict;

use strict;
use warnings;

use XML::LibXML ();
use Types::Serialiser;
use Data::Dumper qw(Dumper);

our $PARSER = XML::LibXML->new();

our $X2A = 0;
our %X2A = ();


our %X2D;
%X2D = (
    order => 0,
    attr  => '-',
    text  => '#text',
    join  => "\n",
    trim  => 1,
    cdata => undef,
    comm  => undef,
    #cdata  => '#',
    #comm   => '//',
    load_ext_dtd    => 0,
    expand_entities => 0,
    expand_xinclude => 0,
    validation      => 0,
    no_network      => 1,
    # to be used in _x2d
    txt_sub         => sub {},
    %X2D,  # also inject previously user-defined options
);


our %D2X;
    %D2X = (
    %X2D,
    #attr   => '-',
    #text   => '~',
    #trim   => 1,
    # join   => '+', # useless
    %D2X,
);
our $AL = length $D2X{attr};

our $hd = '/';

sub _croak { require Carp; goto &Carp::croak }
sub import {
    my $me = shift;
    no strict 'refs';

    my %e = ( 
        xml2dict => 1, 
        dict2xml => 1, 
        ':inject' => 0 
    );

    if (@_) { %e = map { $_=>1 } @_ }

    *{caller().'::xml2dict'} = \&xml2dict if delete $e{xml2dict};
    *{caller().'::dict2xml'} = \&dict2xml if delete $e{dict2xml};

    if ( delete $e{':inject'} ) {
        unless (defined &XML::LibXML::Node::toDict) {
            *XML::LibXML::Node::toDict = \&xml2dict;
        }
    }
    _croak "@{[keys %e]} is not exported by $me" if %e;
}


sub _d2x {
    @_ or return;
    my ($data,$parent) = @_;
    #warn "> $d";
    return unless defined $data;
    if ( !ref $data ) {
        if ($D2X{trim}) {
            $data =~ s/^\s+//s;
            $data =~ s/\s+$//s;
            #return unless length($data);
        }
        return XML::LibXML::Text->new($data)
    };
    my @rv;
    if (ref $data eq 'ARRAY') {
        #warn "Map @$data";
        @rv = map _d2x($_,$parent), @$data;
    }
    elsif (ref $data eq 'HASH') {
        for (keys %$data) {
            #warn "$_ $data->{$_}";
            #next if !defined $data->{$_} or ( !ref $data->{$_} and !length $data->{$_} );
            
            # What may be empty ?
            # - attribute
            # - node
            # - comment
            # Skip empty: text, cdata
            
            my $cdata_or_text;
            
            if ($_ eq $D2X{text}) {
                $cdata_or_text = 'XML::LibXML::Text';
            }
            elsif (defined $D2X{cdata} and $_ eq $D2X{cdata}) {
                $cdata_or_text = 'XML::LibXML::CDATASection';
            }
            
            if (0) {}
            
            elsif($cdata_or_text) {
                push @rv, map {
                    defined($_) ? do {
                        $D2X{trim} and s/(?:^\s+|\s+$)//sg;
                        $D2X{trim} && !length($_) ? () :
                        $cdata_or_text->new( $_ )
                    } : (),
                } ref $data->{$_} ? @{ $data->{$_} } : $data->{$_};
                
            }
            elsif (defined $D2X{comm} and $_ eq $D2X{comm}) {
                push @rv, map XML::LibXML::Comment->new(defined $_ ? $_ : ''), ref $data->{$_} ? @{ $data->{$_} } : $data->{$_};
            }
            elsif (substr($_,0,$AL) eq $D2X{attr} ) {
                if ($parent) {
                    $parent->setAttribute( substr($_,1),defined $data->{$_} ? $data->{$_} : '' );
                } else {
                    warn "attribute $_ without parent" 
                }
            }
            elsif ( !defined $data->{$_} or ( !ref $data->{$_} and !length $data->{$_} ) ) {
                push @rv,XML::LibXML::Element->new($_);
            }
            else {
                local $hd = $hd.'/'.$_;
                my $node = XML::LibXML::Element->new($_);
                #warn ("$hd << ".$_->nodeName),
                $node->appendChild($_) for _d2x($data->{$_},$node);
                push @rv,$node;
            }
        }
    }
    elsif (ref $data eq 'SCALAR') { # RAW
        my $node = eval { XML::LibXML->new->parse_string($$data) } or _croak "Malformed raw data on $hd: $@";
        return $node->documentElement;
    }
    elsif (ref $data eq 'REF') { # LibXML Node
        if (ref $$data and eval{ $$data->isa('XML::LibXML::Node') }) {
            return $$data->cloneNode(1);
        }
        elsif ( ref $$data and do { no strict 'refs'; exists ${ ref($$data).'::' }{'(""'} } ) {
            return XML::LibXML::Text->new( "$$data" );
        }
        else {
            _croak ("Bad reference ".ref( $$data ).": <$$data> on $hd");
        }
    }
    elsif (Types::Serialiser::is_bool( $data )) {
        return XML::LibXML::Text->new( $data ? "true" : "false" );
    }
    elsif ( do { no strict 'refs'; exists ${ ref($data).'::' }{'(""'} } ) { # have string overload
        return XML::LibXML::Text->new( "$data" );
    }
    elsif (ref $data and eval{ $data->isa('XML::LibXML::Node') }) {
        return $data->cloneNode(1);
    }
    else {
        _croak "Bad reference ".ref( $data ).": <$data> on $hd";
    }
    #warn "@rv";
    return wantarray ? @rv : $rv[0];
}


sub _x2d {
    my $doc = shift;
    my $res;

    my $text  = $X2D{text};
    my $join  = $X2D{join};

    unless($doc->hasChildNodes or $doc->hasAttributes) {
        my $txt = $doc->textContent;

        $res = $txt;
        if (my $s = $X2D{txt_sub}) {
            $s->(\$res);
        }
        if ($X2D{trim}) {
            $res =~ s{^\s+}{}s;
            $res =~ s{\s+$}{}s;
        }
    }else{
        my @children   = $doc->childNodes;
        my @nodes_attr = $doc->attributes;

        $res = {};
        for my $a (@nodes_attr) {
           $res->{ $X2D{attr} . $a->nodeName } = $a->getValue;
        }

        for my $ch_node (@children) {
            my $ref_cn = ref $ch_node;

            # child node name
            my $cnn;

            if ($ref_cn eq 'XML::LibXML::Text') {
                $cnn = $text
            }
            elsif ($ref_cn eq 'XML::LibXML::CDATASection') {
                $cnn = defined $X2D{cdata} ? $X2D{cdata} : $text;
            }
            elsif ($ref_cn eq 'XML::LibXML::Comment') {
                $cnn = defined $X2D{comm} ? $X2D{comm} : next;
            }
            else {
                $cnn = $ch_node->nodeName;
            }

            my $ch_data = _x2d($ch_node);

            if (( $X2A or $X2A{$cnn} ) and !$res->{$cnn}) { 
                $res->{$cnn} = [];

            };

            if (exists $res->{$cnn} ) {
                $res->{$cnn} = [ $res->{$cnn} ] unless ref $res->{$cnn} eq 'ARRAY';

                 if (defined $ch_data){
                    if (ref $ch_data eq 'HASH') {
                        my @k = keys %$ch_data;
                        if (@k == 1) {
                            my $k = shift @k;
                            $ch_data = $ch_data->{$k};
                        }
                    }

                    if (ref $ch_data eq 'ARRAY') {
                        push @{$res->{$cnn}}, @$ch_data;
                    }else{
                        push @{$res->{$cnn}}, $ch_data;
                    }
                }
            } else {
                if ($cnn eq $text) {
                    $res->{$cnn} = $ch_data if length $ch_data;
                } else {
                    $res->{$cnn} = $ch_data;
                }
            }
        }
        # end loop over child nodes

        if (defined $join 
            and exists $res->{ $text } 
            and ref $res->{ $text })                          
        {
            $res->{ $text } = join $join, grep length, @{ $res->{ $text } };
        }

        delete $res->{ $text }
            if $X2D{trim} 
                and keys %$res > 1 
                and exists $res->{ $text } 
                and !length $res->{ $text };

        return $res->{ $text } 
            if keys %$res == 1 
            and exists $res->{ $text };

        $res = undef unless (keys %$res);
    }

    return $res;
    
}

sub xml2dict($;%) {
    my ($doc,%opts) = @_;

    defined $doc or _croak("Called xml2dict on undef"),return;

    my $arr = delete $opts{array};

    local $X2A = 1 if defined $arr and !ref $arr;
    local @X2A{@$arr} = (1)x@$arr if defined $arr and ref $arr;

    local @X2D{keys %opts} = values %opts if @_;

    $PARSER->load_ext_dtd($X2D{load_ext_dtd});
    $PARSER->expand_entities($X2D{expand_entities});
    $PARSER->expand_xinclude($X2D{expand_xinclude});
    $PARSER->validation($X2D{validation});
    $PARSER->no_network($X2D{no_network});

    $doc = $PARSER->parse_string($doc) if !ref $doc;
    #use Data::Dumper;
    #warn Dumper \%X2D;
    my $root = $doc->isa('XML::LibXML::Document') ? $doc->documentElement : $doc;

    my $rnn = scalar $root->nodeName;

    my $xa = $X2A || $X2A{$rnn};
    my $d = _x2d($root);

    return {
        $rnn => $xa ? [$d] : $d
    };

}

sub dict2xml($;%) {
    #warn "dict2xml(@_) from @{[ (caller)[1,2] ]}";
    my $hash = shift;
    my %opts = @_;
    my $str = delete $opts{doc} ? 0 : 1;
    my $encoding = delete $opts{encoding} || delete $opts{enc} || 'utf-8';
    my $doc = XML::LibXML::Document->new('1.0', $encoding);
    local @D2X{keys %opts} = values %opts if @_;
    local $AL = length $D2X{attr};
    #use Data::Dumper;
    #warn Dumper \%D2X;
    my $root = _d2x($hash);
    $doc->setDocumentElement($root);
    return $str ? $doc->toString : $doc;
}


1; # End of Base::XML::Dict
 
=head1 NAME

Base::XML::Dict - Convert hash to xml and xml to hash using LibXML

=head1 SYNOPSIS

    use Base::XML::Dict;

    my $hash = xml2dict $xmlstring, attr => '.', text => '~';
    my $hash = xml2dict $xmldoc;
    
    my $xmlstr = hash2html $hash, attr => '+', text => '#text';
    my $xmldoc = hash2html $hash, doc => 1, attr => '+';
    
    # Usage with XML::LibXML

    my $doc = XML::LibXML->new->parse_string($xml);
    my $xp  = XML::LibXML::XPathContext->new($doc);
    $xp->registerNs('rss', 'http://purl.org/rss/1.0/');

    # then process xpath
    for ($xp->findnodes('//rss:item')) {
        # and convert to hash concrete nodes
        my $item = xml2dict($_);
        print Dumper+$item
    }

=head1 DESCRIPTION

This module is a companion for C<XML::LibXML>. It operates with LibXML objects, could return or accept LibXML objects, and may be used for easy data transformations

It is faster in parsing then L<XML::Simple>, L<XML::Hash>, L<XML::Twig> and of course much slower than L<XML::Bare> ;)

It is faster in composing than L<XML::Hash>, but slower than L<XML::Simple>

Parse benchmark:

               Rate   Simple     Hash     Twig Hash::LX     Bare
    Simple   11.3/s       --      -2%     -16%     -44%     -97%
    Hash     11.6/s       2%       --     -14%     -43%     -97%
    Twig     13.5/s      19%      16%       --     -34%     -96%
    Hash::LX 20.3/s      79%      75%      51%       --     -95%
    Bare      370/s    3162%    3088%    2650%    1721%       --

Compose benchmark:

               Rate     Hash Hash::LX   Simple
    Hash     49.2/s       --     -18%     -40%
    Hash::LX 60.1/s      22%       --     -26%
    Simple   81.5/s      66%      36%       --

Benchmark was done on L<http://search.cpan.org/uploads.rdf>

=head1 EXPORT

C<xml2dict> and C<dict2xml> are exported by default

=head2 :inject

Inject toDict method in the namespace of L<XML::LibXML::Node> and allow to call it on any subclass of L<XML::LibXML::Node> directly

By default is disabled

    use Base::XML::Dict ':inject';
    
    my $doc = XML::LibXML->new->parse_string($xml);
    my $hash = $doc->toDict(%opts);

=head1 FUNCTIONS

=head2 xml2dict $xml, [ OPTIONS ]

XML could be L<XML::LibXML::Document>, L<XML::LibXML::DocumentPart> or string

=head2 dict2xml $hash, [ doc => 1, ] [ OPTIONS ]

Id C<doc> option is true, then returned value is L<XML::LibXML::Document>, not string

=head1 OPTIONS

Every option could be passed as arguments to function or set as global variable in C<Base::XML::Dict> namespace

=head2 %Base::XML::Dict::X2D

Options respecting convertations from xml to hash

=over 4

=item order [ = 0 ]

B<Strictly> keep the output order. When enabled, structures become more complex, but xml could be completely reverted

=item attr [ = '-' ]

Attribute prefix

    <node attr="test" />  =>  { node => { -attr => "test" } }

=item text [ = '#text' ]

Key name for storing text

    <node>text<sub /></node>  =>  { node => { sub => '', '#text' => "test" } }

=item join [ = '' ]

Join separator for text nodes, splitted by subnodes

Ignored when C<order> in effect

    # default:
    xml2dict( '<item>Test1<sub />Test2</item>' )
    : { item => { sub => '', '~' => 'Test1Test2' } };
    
    # global
    $Base::XML::Dict::X2D{join} = '+';
    xml2dict( '<item>Test1<sub />Test2</item>' )
    : { item => { sub => '', '~' => 'Test1+Test2' } };
    
    # argument
    xml2dict( '<item>Test1<sub />Test2</item>', join => '+' )
    : { item => { sub => '', '~' => 'Test1+Test2' } };

=item trim [ = 1 ]

Trim leading and trailing whitespace from text nodes

=item cdata [ = undef ]

When defined, CDATA sections will be stored under this key

    # cdata = undef
    <node><![CDATA[ test ]]></node>  =>  { node => 'test' }

    # cdata = '#'
    <node><![CDATA[ test ]]></node>  =>  { node => { '#' => 'test' } }

=item comm [ = undef ]

When defined, comments sections will be stored under this key

When undef, comments will be ignored

    # comm = undef
    <node><!-- comm --><sub/></node>  =>  { node => { sub => '' } }

    # comm = '/'
    <node><!-- comm --><sub/></node>  =>  { node => { sub => '', '/' => 'comm' } }

=item load_ext_dtd [ = 0 ]

Load the external DTD

    # load_ext_dtd = 0
    <!DOCTYPE foo [<!ENTITY % ent1 SYSTEM "rm -rf /">%ent1; ]><node> text</node>
    
    # load_ext_dtd = 1
    <!DOCTYPE foo [<!ENTITY % ent1 SYSTEM "rm -rf /">%ent1; ]><node> text</node>
    oops!


=item expand_entities [ = 0 ]

Enable XInclude substitution. (See L<XML::LibXML::Parser>)

=item expand_xinclude [ = 0 ]

Enable entities expansion. (See L<XML::LibXML::Parser>). (Enabling also enables load_ext_dtd)

=item validation [ = 0 ]

Enable validating with the DTD. (See L<XML::LibXML::Parser>)

=item no_network [ = 1 ]

Forbid network access; (See L<XML::LibXML::Parser>)

If true, all attempts to fetch non-local resources (such as DTD or external entities) will fail

=back

=head2 $Base::XML::Dict::X2A [ = 0 ]

Global array casing

Ignored when C<X2D{order}> in effect

As option should be passed as

    xml2dict $xml, array => 1;

Effect:

    # $X2A = 0
    <node><sub/></node>  =>  { node => { sub => '' } }

    # $X2A = 1
    <node><sub/></node>  =>  { node => [ { sub => [ '' ] } ] }

=head2 %Base::XML::Dict::X2A

By element array casing

Ignored when C<X2D{order}> in effect

As option should be passed as

    xml2dict $xml, array => [ nodes list ];

Effect:

    # %X2A = ()
    <node><sub/></node>  =>  { node => { sub => '' } }

    # %X2A = ( sub => 1 )
    <node><sub/></node>  =>  { node => { sub => [ '' ] } }

=head2 %Base::XML::Dict::D2X

Options respecting convertations from hash to xml

=over 4

=item encoding [ = 'utf-8' ]

XML output encoding

=item attr [ = '-' ]

Attribute prefix

    { node => { -attr => "test", sub => 'test' } }
    <node attr="test"><sub>test</sub></node>

=item text [ = '#text' ]

Key name for storing text

    { node => { sub => '', '#text' => "test" } }
    <node>text<sub /></node>
    # or 
    <node><sub />text</node>
    # order of keys is not predictable

=item trim [ = 1 ]

Trim leading and trailing whitespace from text nodes

    # trim = 1
    { node => { sub => [ '    ', 'test' ], '#text' => "test" } }
    <node>test<sub>test</sub></node>

    # trim = 0
    { node => { sub => [ '    ', 'test' ], '#text' => "test" } }
    <node>test<sub>    test</sub></node>

=item cdata [ = undef ]

When defined, such key elements will be saved as CDATA sections

    # cdata = undef
    { node => { '#' => 'test' } } => <node><#>test</#></node> # it's bad ;)

    # cdata = '#'
    { node => { '#' => 'test' } } => <node><![CDATA[test]]></node>

=item comm [ = undef ]

When defined, such key elements will be saved as comment sections

    # comm = undef
    { node => { '/' => 'test' } } => <node></>test<//></node> # it's very bad! ;)

    # comm = '/'
    { node => { '/' => 'test' } } => <node><!-- test --></node>

=back

=head1 BUGS

None known

=head1 SEE ALSO

=over 4

=item * L<XML::Parser::Style::EasyTree>

With default settings should produce the same output as this module. Settings are similar by effect

=back

=head1 AUTHOR

Mons Anderson, C<< <mons at cpan.org> >>

=head1 LICENSE

Copyright 2009-2020 Mons Anderson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

