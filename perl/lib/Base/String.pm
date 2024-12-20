
package Base::String;

use strict;
use warnings;

=head1 NAME

Base::String - module for working with strings

=cut

use Exporter ();
use base qw(Exporter);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use String::Util qw(trim);
use Base::List qw(uniq);

@ISA     = qw(Exporter);
@EXPORT  = qw( );
$VERSION = '0.01';

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
        str_split
        str_split_sn
        str_split_trim
        str_split_pm
        str_sum
        str_eq
        str_env
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

#sub opts2dict {
  #my ($opts_s) = @_;
  #no strict;

  #return unless defined $opts_s;

  #my @opts = grep { length } map { defined ? trim($_) : () } split("," => $opts_s);

  #return unless @opts;
  #my $dict = {};
  #my $pat = qr/^([^=]+)(?:\s*|=([^=]+))$/;

  #for(@opts){
     #my ($k, $v) = (m/$pat/);
     #$k = trim($k);

     #$dict->{$k} = defined $v ? trim($v) : 1;
  #}

  #return $dict;
#}

sub str_split_sn {
    my ($str) = @_;

    my $sep = qr/[\s\n]/;
    my @s = str_split($str,{ sep => $sep });
    return @s;
}

sub str_env {
  my ($str) = @_;

  my $env = sub { 
    my $vname = shift; 

    $ENV{uc $vname} // ''; 
  };

  my $re = ($^O eq 'MSWin32') ? qr/%(\w+)%/ : qr/\$(\w+)/;

  local $_ = $str;
  while(/$re/){
    my $vname = $1;
    my $vval  = $env->($vname);
    s/$re/$vval/g;
  }
  return $_;
}

sub str_split {
    my ($str,$ref) = @_;

    return () unless $str;

    $ref ||= {};

    my @res;
    if (ref $str eq "ARRAY"){
        foreach my $s (@$str) {
            push @res, str_split($s,$ref);
        }
        @res = uniq(\@res) if ($ref->{uniq});
        return @res;
    }elsif( not ( ref $str eq "" ) ){
        return ();
    }

    my $c   = $ref->{comment_start}  || '#';
    my $sep = $ref->{sep}  || "\n";

    @res = 
        map { trim($_) } 
        grep { !/^\s*$/ && !/^\s*$c/ } 
        split( $sep => $str );

    @res = uniq(\@res) if ($ref->{uniq});

    wantarray ? @res : \@res;
}

sub str_split_pm {
    my ($str,$ref) = @_;

    return () unless $str;

    my (%pm, @split);

    @split = str_split ($str, $ref);

    for(@split){
        /^\+(.*)/  && do { $pm{$1} ||= 0; $pm{$1}++;  next;  };
        /^\-(.*)/  && do { $pm{$1} ||= 0; $pm{$1}--;  next;  };
        /^(.*)/    && do { $pm{$1} = 1;   next;  };
    }

    return {%pm};
}

sub str_split_trim {
    my ($text, $sep) = @_;
    $sep ||= "\n";

    my @a = map { 
        s/^\t*//g; 
        s/^\s*//g; 
        s/\s*$//g; 
        length > 0 ? $_ : ()
    } split $sep => $text;

    return @a;
}



sub str_eq {
    my ($y,$z)=@_;

    my $ok=1;
    my $h_y = str_split_pm($y);
    my $h_z = str_split_pm($z);

    for (keys %$h_y){
        my $v_z = $h_z->{$_} || 0;
        my $v_y = $h_y->{$_} || 0;
        unless ( $v_y == $v_z ) {
            $ok = 0; last;
        }
    }
    return $ok;
}

sub str_sum {
    my ($old, $new, $ref) = @_;

    my (%sum);

    $old = str_split_pm($old, $ref );
    $new = str_split_pm($new, $ref );

    my @keys = (keys %$old, keys %$new ); 

    for my $k (@keys){
        my $v_new = $new->{$k} || 0;
        my $v_old = $old->{$k} || 0;

        $sum{$k} = $v_old  + $v_new;
    }

    my $s = '';
    while(my($k,$v) = each %sum){
        next unless ($v > 0);

        $s .= "\n" . $k;
    }
    return $s;
}

1;
 

