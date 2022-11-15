
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

use Base::String qw(
    str_split
    str_split_trim
);
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
        dict_new
        dict_rm_ctl

        dict_expand_env

        hash_inject
        hash_apply

        v_copy

        opts2dict
        d2dict
        d2list
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

sub d2list {
  my ($d, $key) = @_;

  my @list;

  my $dk = $d->{'@' . $key} || $d->{$key} || '';
  if (!ref $dk) {
     push @list, str_split_trim($dk => ",");

  } elsif (ref $dk eq 'ARRAY') {
     foreach my $item (@$dk) {
        push @list, str_split_trim($item => ",");
     }
  }

  wantarray ? @list : \@list;
}

sub d2dict {
  my ($d, $key) = @_;

  my $dict={};

  my $dk = $d->{'@' . $key} || $d->{$key} || '';
  if (ref $dk eq 'ARRAY') {
     for(@$dk) {
        my $dd = opts2dict($_) || {};
        dict_update($dict, $dd);
     }
  }
  elsif (!ref $dk) {
     my $dd = opts2dict($dk) || {};
     dict_update($dict, $dd);
  }

  return $dict;
}

sub opts2dict {
  my ($opts_s) = @_;

  return unless defined $opts_s;

  my @opts = grep { length } map { defined ? trim($_) : () } split("," => $opts_s);

  return unless @opts;
  my $dict = {};

  for(@opts){
     my ($k, $v) = (/^([^=]+)(?:|=([^=]+))$/g);
     $k = trim($k);

     $dict->{$k} = defined $v ? trim($v) : 1;
  }

  return $dict;
}

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

sub dict_rm_ctl {
    my ($dict) = @_;

    foreach my $k (keys %$dict) {
        my $v_dict = $dict->{$k};

        my ($km, $ctl_line) = str_split($k, { 'sep' => '@' });
        if($ctl_line){
           $dict->{$km} = $v_dict;
           delete $dict->{$k};
        }

        if (ref $v_dict eq 'HASH') {
           dict_rm_ctl($dict->{$km});
        }
    }
}

# my $d = {};
# dict_new('a.b.c','aa');
sub dict_new {
   my ($path, $val, $sep) = @_;
   $sep ||= '\.';

   my $dcn;
   $dcn = sub { 
      my ($dct, $path, $val) = @_;

      while ($path =~ /^\Q$sep\E/) {
        $path = substr $path, 1;
      }
      my @parts = split $sep => $path, 2;

      my $front = $parts[0];

      if (@parts > 1) {
        $dct->{$front} ||= {};
        my $branch = $dct->{$front};
        $dcn->($branch, $parts[1], $val);
      }else{
        unless (exists $dct->{$front}) {
          $dct->{$front} = $val;
        }
      }
   };

   my $d = {};
   $dcn->($d,$path,$val);
   return $d;
}

#def dictnew(path='', val='', sep='.'):
  #''' 
    #d = dictnew('a.b.c.d',value)
    #d = dictnew('a/b/c/d',value,sep='/')
  #''' 
  #def _dictnew(dct, path, val):
    #while path.startswith(sep):
      #path = path[1:]
    #parts = path.split(sep, 1)
    #if len(parts) > 1:
        #branch = dct.setdefault(parts[0], {})
        #_dictnew(branch, parts[1], val)
    #else:
        #if not parts[0] in dct:
          #dct[parts[0]] = val

  #d = {}
  #_dictnew(d,path,val)
  #return d

sub dict_update {
    my ($dict, $update, $opts) = @_;

    $opts ||= {};

    return unless $dict && reftype $dict eq 'HASH';
    return unless $update && reftype $update eq 'HASH';

    foreach my $k (keys %$update) {
        my $v_upd  = $update->{$k};
        next unless defined $v_upd;

        my ($km, $ctl_line) = str_split($k, { 'sep' => '@' });
        my %ctl = map { $_ => 1 } str_split($ctl_line, { 'sep' => ',' });
        $k = $km if keys(%ctl) && $opts->{ctl};

        my $v_dict = $dict->{$k};
        #$DB::single = 1 if $k eq 'sections';

        my $d_type  = defined $v_dict ? ( reftype $v_dict || '' ) : '';
        my $u_type  = defined $v_upd ? ( reftype $v_upd || '' ) : '';

        if ($d_type eq $u_type) {
          if($d_type eq 'HASH'){
             dict_update($v_dict, $v_upd, $opts);
             next;

          }elsif($d_type eq 'ARRAY'){
             if($opts->{ctl}){
               my $done;

               $v_dict ||= [];
               if($ctl{push}){
                  push @$v_dict, @$v_upd;  $done = 1;
               }
               if($ctl{prepend}){
                  unshift @$v_dict, @$v_upd; $done = 1;
               }
               if($ctl{uniq}){
                  $v_dict = uniq($v_dict); $done = 1;
               }
               $dict->{$k} = $v_dict;
    
               next if $done;
             }
          }
        }

        if($d_type eq ''){
          if ($u_type eq 'ARRAY') {
            if ($ctl{push} && $opts->{ctl}) {
              $dict->{$k} = [];
              push @{$dict->{$k}}, defined $v_dict ? $v_dict : (), @$v_upd;
              next;
            }
          }
        }

        $dict->{$k} = $v_upd;
    }

    return $dict;
}

sub dict_expand_env {
    my ($dict) = @_;

    return unless $dict && ref $dict eq 'HASH';

    while(my($k, $v) = each %{$dict}){
        if (ref $v eq "HASH"){
           dict_expand_env($v);

        }elsif(! ref $v){
           $v =~ s|\@env\{(\w+)\}|$ENV{$1} // ''|ge;
        }

        $dict->{$k} = $v;
    }

}

1;
 

