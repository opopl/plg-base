
package Base::HTML::Page;

use strict;
use warnings;

use HTML::HTML5::Writer;
use XML::LibXML;
use XML::LibXML::PrettyPrint;


sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

#eval {
    #no strict 'refs';

    #foreach my $n ((1 .. 4 )) {
        #my $s = 'h' . $n;
        #*{__PACKAGE__ . '::h' . $s } = sub { };
    #}
#} or die "Can't modify the symbol table: $!";



sub _str {
    my ($self, $ref) = @_;

    my $dom = $self->{dom};
    my $wr  = $self->{wr};

    my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
    $pp->pretty_print($dom); # modified in-place

    my $str = $wr->document($dom);

	foreach my $k (qw( text_update line_update )) {
    	my $sub = $ref->{$k};
	    if ( $sub && ref $sub eq 'CODE' ) {

			for($k){
				/^text_update$/ && do { 
    				local $_ = $str;
	        		$sub->();
					$str = $_;
					last;
				};

				/^line_update$/ && do { 
					my @lines = split("\n",$str);
					foreach(@lines) {
						chomp;
	        			$sub->();
					}
					$str = join("\n",@lines);
					last;
				};

				last;

			}
	    }
	}

    #s/\&/\&amp;/\&/g; 

    #s/\&/\&amp;/g; 
    #s/</\&lt;/g; 
    #s/>/\&gt;/g; 
    #s/"/\&quot;/g; 
    #s/'"'"'/\&apos;/g;

    return $str;
}

sub init {
    my $self = shift;

    my $h = {
        title => '',
    };
        
    my @k = keys %$h;

    for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

    $self
        ->start
        ;

    return $self;
}

sub update {
    my ($self, $ref) = @_;

    $ref ||= {};

	my $sub   = $ref->{sub};
	my $xpath = $ref->{xpath};

	unless ($xpath && $sub) {
		return $self;
	}

    my $dom = $self->{dom};
	$dom
		->findnodes($xpath)
		->map($sub);

    return $self;
}

sub add {
    my ($self, $tg, $ref) = @_;

    $ref ||= {};

    my $text  = $ref->{text};
    my $attr  = $ref->{attr};

    my $dom = $self->{dom};

    my $e = $dom->createElement($tg);

    if ($text) {
        $e->appendText($text);
    }

    if ($attr) {
        foreach my $x (keys %$attr) {
            my $v = $attr->{$x};
            next unless $v;
    
            $e->{$x} = $v;
        }
    }

    $dom
        ->findnodes('/html/body')
        ->map(sub { 
                my ($n) = @_;

                $n->appendChild($e); 
            }
        );

    return $self;
}

sub start {
    my ($self) = @_;

    my $wr = HTML::HTML5::Writer->new(
        doctype    => '<!doctype html>',
        start_tags => 'force',
        end_tags   => 'force',
    );
    $self->{wr} = $wr;

    my $dom = XML::LibXML::Document->createDocument();
    $self->{dom} = $dom;

    my $title = $self->{title};

    my $el = {};

    my @tags = qw(html head body title);
    foreach my $x (@tags) {
        $el->{$x} = $dom->createElement($x);
    }

    my $meta = {
        'http-equiv' => "Content-Type",
        'content'    => "text/html; charset=utf-8",
    };

    $el->{meta} = [];
    foreach my $k (keys %$meta) {
        my $v = $meta->{$k};

        my $e = $dom->createElement('meta');
        $e->setAttribute($k => $v);

        push @{$el->{meta}}, $e;
    }

    $el->{title}->appendText($title);

    $el->{head}->appendChild($el->{title});

    foreach my $e (@{$el->{meta}}) {
        $el->{head}->appendChild($e);
    }

    foreach my $y (qw(head body)) {
        $el->{html}->appendChild($el->{$y});
    }
    $dom->setDocumentElement($el->{html});

    return $self;

}

1;
 

