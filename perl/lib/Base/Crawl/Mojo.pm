
package Base::Crawl::Mojo;

use 5.010;
use open qw(:locale);
use strict;
use utf8;

use warnings qw(all);

use Data::Dumper qw(Dumper);

use Mojo::UserAgent;
use Base::Arg qw( hash_inject );
use YAML qw(LoadFile);
use Getopt::Long qw(GetOptions);
use FindBin qw($Bin $Script);

use base qw(
    Base::Cmd
);

# FIFO queue
my @urls = map { Mojo::URL->new($_) } qw(
    www.bbc.com
);

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub load_yaml {
    my ($self) = @_;

    my $f_yaml = $self->{f_yaml};
	return $self unless $f_yaml;

    my $data = LoadFile($f_yaml);

    foreach my $k (keys %$data) {
        $self->{$k} = $$data{$k};
    }

    return $self;
}

sub init {
    my ($self) = @_;
    
    my $h = {
    	ua => Mojo::UserAgent->new(max_redirects => 5),
		loop => { 
			active => 0,
    		# Limit parallel connections to 4
			max_conn => 4,
		}
    };
        
    hash_inject($self, $h);
    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->get_opt
        ->load_yaml
        ->run_cmd
        ;

    return $self;
}
      
sub get_opt {
    my ($self) = @_;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    my (@optstr, %opt);
    @optstr = ( 
        "help|h=s",
        "f_yaml|y=s",
        "cmd|c=s",
    );
    
    unless( @ARGV ){ 
        $self->dhelp;
        exit 0;
    }else{
        GetOptions(\%opt,@optstr);
        $self->{opt} = \%opt;
    }

    foreach my $k (keys %opt) {
        $self->{$k} = $opt{$k};
    }

    return $self;   
}

sub dhelp {
    my ($self) = @_;

    my $s = qq{

    USAGE
        perl $Script OPTIONS
    OPTIONS

    EXAMPLES
        perl $Script -y 1.yaml -c run

    };

    print $s . "\n";

    return $self;   
}

sub cmd_run {
    my ($self) = @_;

	my $ua = $self->{ua};
    $ua->proxy->detect;
    
    Mojo::IOLoop->recurring(
        0 => sub {
            for ($self->{loop}->{active} + 1 .. $self->{loop}->{max_conn}) {
                my $url = shift @urls;
    
                # Dequeue or halt if there are no active crawlers anymore
                return ($self->{loop}->{active} or Mojo::IOLoop->stop) unless $url;
    
                # Fetch non-blocking just by adding
                # a callback and marking as active
                ++$self->{loop}->{active};
                $self->{ua}->get($url => $self->cb_ua_get );
            }
        }
    );

    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

    return $self;
}

# Start event loop if necessary

sub cb_ua_get {
	my ($self) = @_;

	sub { 
	    my (undef, $tx) = @_;
	
	    # Deactivate
	    --$self->{loop}->{active};
	
	    # Parse only OK HTML responses
	    return unless ( $tx->res->is_success && $tx->res->headers->content_type =~ m{^text/html\b}ix );
	
	    # Request URL
	    my $url = $tx->req->url;
	
	    say $url;
	    $self->parse_html($url, $tx);
	
	    return;
	};
}

sub parse_html {
    my ($self, $url, $tx) = @_;

    say $tx->res->dom->at('html title')->text;

    # Extract and enqueue URLs
    for my $e ($tx->res->dom('a[href]')->each) {

        # Validate href attribute
        my $link = Mojo::URL->new($e->{href});
        next if 'Mojo::URL' ne ref $link;

        # "normalize" link
        $link = $link->to_abs($tx->req->url)->fragment(undef);
        next unless grep { $link->protocol eq $_ } qw(http https);

        # Don't go deeper than /a/b/c
        next if @{$link->path->parts} > 3;

        # Access every link only once
        state $uniq = {};
        ++$uniq->{$url->to_string};
        next if ++$uniq->{$link->to_string} > 1;

        # Don't visit other hosts
        next if $link->host ne $url->host;

        push @urls, $link;
        say " -> $link";
    }
    say '';

    return $self;
}

1;

__DATA__
Featured at:
http://blogs.perl.org/users/stas/2013/01/web-scraping-with-modern-perl-part-1.html


1;
 

