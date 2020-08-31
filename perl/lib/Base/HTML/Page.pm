
package Base::HTML::Page;

use strict;
use warnings;

use HTML::HTML5::Writer;
use XML::LibXML;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub _str {
	my $self = shift;

	my $dom = $self->{dom};
	my $wr  = $self->{wr};

    my $str = $wr->document($dom);

	return $str;;
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
 

