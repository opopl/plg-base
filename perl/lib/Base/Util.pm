
package Base::Util;

use strict;
use warnings;

use POSIX qw(strftime);
use Carp qw(carp);

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper qw(Dumper);
use File::Basename qw(basename dirname);
use Digest::MD5;

use Base::Enc qw(
    enc_out 
    enc_in
    enc
    unc_encode
    UNC
);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [qw( 
        replace_undefs
        now
        file_w
        file_r
        dmp
        iswin
        md5sum
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

our @EXPORT  = qw( );

our $VERSION = '0.01';

sub md5sum
{
    my $file = shift;
    my $digest = "";
    eval{
        open(FILE, $file) or die "Can't find file $file\n";
        my $ctx = Digest::MD5->new;
        $ctx->addfile(*FILE);
        $digest = $ctx->hexdigest;
        close(FILE);
    };
    if($@){ print $@; return ""; }
    return $digest; 
}


sub replace_undefs {
    my ($struct) = @_;

    if (ref $struct eq ""){
        $struct = "" unless defined $struct;

    }elsif (ref $struct eq "SCALAR"){
        $$struct = "" unless defined $$struct;

    }elsif (ref $struct eq "ARRAY"){
        foreach my $x (@$struct) {
            $x = replace_undefs($x);
        }

    }elsif(ref $struct eq "HASH"){
        foreach my $x (keys %$struct) {
            my $v = $struct->{$x};
            $struct->{$x} = replace_undefs($v);
        }
    }

    return $struct;
}

sub iswin {
    ($^O eq 'MSWin32') ? 1 : 0;
}

sub dmp {
    my ($ref,$title) = @_;

    my $func = (caller(0))[4];
    my $pack = __PACKAGE__;
    $func =~ s/$pack :://gx;

    $title ||= 'dump';

    my @msg;
    push @msg, 
        Data::Dumper->Dump([$ref],['dump'])
        ;
    

    for(@msg){
        print $_ . "\n";
    }
}

sub now {
    #my $now = POSIX::strftime( "%a %b %e %H:%M:%S %Y", localtime() );
    my $now = localtime(); 
    return $now;
}

=head3 file_w

=head4 Usage

    # $file - SCALAR, lines - ARRAYREF
    file_w({
        file => $file, 
        lines => $lines 
    });

    # $file - SCALAR, text - SCALAR
    file_w({ 
        file => $file, 
        text => $text 
    });

=cut


sub file_w {
    my ($ref) = @_;

    $ref ||= {};
    my @f = qw( file lines text decode enc);
    my ($file, $lines, $text, $decode, $enc) = @{$ref}{@f};

    my $warn = $ref->{warn} || sub { 
        my ($msgs) = @_;
        warn $_ . "\n" for(@$msgs);
    };

    my $binmode = enc($enc);
    $binmode = $ref->{binmode} if defined $ref->{binmode};

    $lines ||= [];
    $text  ||= '';

    if ( (ref $lines eq 'ARRAY') && (@$lines) ){
        $text .= join("\n",@$lines);
    }

    if ($decode) {
        $text = $decode->($text);
    }
    #$text =~ s/\r//gms;


    {
        my $fh;
        #local $|=1;
        my $msg = "Failure to write file: $file";
        open ($fh, '>', $file) || carp "$! $msg";

        if($binmode){
            binmode $fh, $binmode;
        }else{
            binmode $fh;
        }
        eval { print $fh $text; };
        if ($@) { 
            my $r = { 
                enc    => $enc,
                file   => $file,
                decode => $decode,
            };
            my @msgs;
            push @msgs, 
                '(file_w) Failures while printing to file',
                Dumper($r),
                $@
                ;
            $warn->(\@msgs); 
        }
        #eval { print $fh $text; };
        #eval { local $SIG{__WARN__} = sub{}; print $fh $text; };
        close $fh;
    }

}

sub file_r {
    my ($ref) = @_;

    $ref ||= {};
    my @f = qw( file lines enc text );
    my ( $file, $lines, $enc, $text ) = @{$ref}{@f};

    $lines ||= [];
    $text ||= '';

    $enc ||= UNC;

    my $warn = $ref->{warn} || sub { 
        my ($msgs) = @_;
        warn $_ . "\n" for(@$msgs);
    };

    #$ref->{raw} ||= 1;
    $ref->{slurp} ||= 1;

    open my $out, '<', $file;
    binmode $out, sprintf('%s:encoding(%s)',( $ref->{raw} ? ':raw' : '' ), $enc);

    eval {
        local $SIG{__WARN__} = sub {
            my $msgs = [
                'file: ' . basename($file),
                'slurp warn:'
            ];
            push @$msgs, @_;
            $warn->($msgs);
        };

        unless ($ref->{slurp}) {
            for(<$out>){
                chomp;
                push @$lines, $_;
            }
        }else{
            local $/ = undef;
            $text = <$out>;
            @$lines = split("\n",$text);
        }
    };
    if ($@) { 
        my $r = { 
            enc    => $enc,
            file   => $file,
        };
        my @msgs;
        push @msgs, 
            '(file_r) Failures while reading file',
            Dumper($r),
            $@
            ;
        $warn->(\@msgs); 
    }
    close $out;

    return $lines;

}


1;
 

