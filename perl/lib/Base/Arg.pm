
package Base::Arg;

use strict;
use warnings;

use Clone qw(clone);

#use Deep::Hash::Utils qw(reach slurp nest deepvalue);
use Hash::Merge qw(merge);
use Data::Dumper qw(Dumper);

use Scalar::Util qw(blessed reftype);

use Exporter ();
use base qw(Exporter);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA     = qw(Exporter);
@EXPORT  = qw( );
$VERSION = '0.01';

use Base::String qw(str_split);
use String::Util qw(trim);

use Base::List qw(uniq);

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
        arg_to_list
        hash_update

        hash_merge
        hash_merge_left
        hash_merge_right

        dict_update

        hash_inject
        hash_apply

        v_copy

        opts2dict
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub arg_to_list {
    my ($arg) = @_;

    $arg ||= [];

    my @list;
    if (ref $arg eq "ARRAY"){
        @list = @$arg;
        
    }elsif(ref $arg eq ""){
        @list = str_split($arg);
        
    }
    return wantarray ? @list : \@list ;
}

=head2 hash_update

=head3 Purpose

=head3 Usage

    use Base::Arg qw(hash_update);

    my ($hash, $update);

    # update $hash with the contents of 
    #   $update;
    hash_update($hash, $update);

=head3 Examples

=cut    

sub hash_update {
    my ($hash, $update) = @_;

    return unless $update;

    while( my($k, $v) = each %{$update} ){
        $hash->{$k} = $v;
    }
}

sub hash_apply {
    my ($hash, $update) = @_;

    unless (ref $update eq 'HASH') {
        $hash = clone($update);
        return ;
    }

    while( my($k, $v) = each %{$update} ){
        next unless defined $v;

        my $h = $hash->{$k};
        if (defined $h){
            if(ref $h eq 'HASH'){
                if (ref $v eq 'HASH') {
                    hash_apply($h, $v);

                }elsif(ref $v eq 'ARRAY'){
                    my $w = clone($v);
                    $hash->{$k} = [ clone($h), @$w ];

                }elsif(! ref $v){
                    $hash->{$k} = [ clone($h), $v ];
                }
                next;
            }
        }

        my ($txt, %zz);
        if (ref $v eq 'HASH') {
            $txt = $v->{'#text'};
            %zz  = map { $_ => 1 } split("," => $v->{'zz'} || '' );
        }

        while(1){
            # txt node
            unless(ref $h){
                ($txt && $zz{'+'}) && do {
                    $hash->{$k} .= $txt;
                    last;
                };
                ($txt && $zz{'+n'}) && do {
                    $hash->{$k} .= "\n" . $txt;
                    last;
                };

                ($txt) && do {
                    $hash->{$k} = $txt;
                    last;
                };
            }
            elsif(ref $h eq 'ARRAY'){
                my $w = clone($v);

                if(ref $w eq 'ARRAY'){ 
                    foreach my $x (@$w) {
                        my $z = clone($x);
                        push @$h, $z;
                    }
                }
                last;
            } 

            if (blessed($v)) {
                $hash->{$k} = $v;
            }else{
                $hash->{$k} = clone($v);
            }

            last;
        }
    }

    return;
}

sub v_copy {
    my ($v) = @_;

    my $r = ref $v;
    my $w = ($r && grep { /^$r$/ } qw(ARRAY HASH)) ? clone($v) : $v;

    return $w;
}

# recursive injection
sub hash_inject {
    my ($hash, $update) = @_;

    while( my($k, $v) = each %{$update} ){
        my $h = $hash->{$k};
        if (defined $h){
            next unless ref $h;
            next if ref $h eq 'ARRAY';
            next if ref $h eq 'CODE';

            hash_inject($h,$v);
            next;
        }

        if (blessed($v)) {
            $hash->{$k} = $v;
        }else{
            $hash->{$k} = clone($v);
        }
    }

    return;
}

sub dict_update {
    my ($dict, $update, $opts) = @_;

    $opts ||= {};

    return unless reftype $dict eq 'HASH';
    return unless reftype $update eq 'HASH';

    foreach my $k (keys %$update) {
        my $v_upd  = $update->{$k};
        next unless defined $v_upd;

        my ($km, $ctl_line) = str_split($k, { 'sep' => '@' });
        my %ctl = map { $_ => 1 } str_split($ctl_line, { 'sep' => ',' });
        $k = $km if keys(%ctl);

        #$DB::single = 1 if keys(%ctl);

        my $v_dict = $dict->{$k};

        #$DB::single = 1 if $k eq 'include';

        my $d_type  = defined $v_dict ? ( reftype $v_dict || '' ) : '';
        my $u_type  = defined $v_upd ? ( reftype $v_upd || '' ) : '';

        if ($d_type eq $u_type) {
          if($d_type eq 'HASH'){
             dict_update($v_dict, $v_upd);

          }elsif($d_type eq 'ARRAY'){
             my $done;

             if($ctl{push}){
                push @$v_dict, @$v_upd; $done = 1;
             }
             if($ctl{prepend}){
                unshift @$v_dict, @$v_upd; $done = 1;
             }
             if($ctl{uniq}){
                $dict->{$k} = uniq($v_dict); $done = 1;
             }

             next if $done;
          }
        }

        if($d_type eq ''){
          if ($u_type eq 'ARRAY') {
            if ($ctl{push}) {
              $dict->{$k} = [ $v_dict, @$v_upd ];
              next;
            }
          }
        }

        $dict->{$k} = $v_upd;

    }

    return $dict;
}

1;
 

