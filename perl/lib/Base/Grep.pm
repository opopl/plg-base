package Base::Grep;

use strict;
use warnings;

use Base::Arg qw( hash_inject );
use Getopt::Long qw(GetOptions);
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);

use File::Grep qw(fgrep);

use File::Find::Rule;
use Base::DB qw(
    dbi_connect
    dbh_insert_hash
);
      
sub get_opt {
    my ($self) = @_;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    my (@optstr, %opt);
    @optstr = ( 
        "help|h=s",

        # (find) file extensions
        "exts|e=s@",
        # (find) directories
        "dirs|d=s@",

        # (grep)pattern to grep
        "pat|p=s",
    );
    
    unless( @ARGV ){ 
        $self->dhelp;
        exit 0;
    }else{
        GetOptions(\%opt,@optstr);
        $self->{opt} = \%opt;
    }

    while(my($k,$v) = each %opt){

        if (grep { /^$k$/ } qw(exts)) {
           $self->{$k} ||= [];

           my @arr;  
           if (ref $v eq 'ARRAY') {
             for my $x (@$v){
                push @arr, split(',' => $x);
             }
           }else{
             push @arr, split(',' => $v);
           }

           push @{$self->{$k}}, @arr;

           next;
        }

        $self->{$k} = $v;
    }

    return $self;   
}

sub dhelp {
    my ($self) = @_;

    my $s = qq{

    USAGE
        perl $Script OPTIONS
    OPTIONS
       find
          @ --exts -e (STRING, comma-separated list) extensions 
          @ --dirs -d (STRING) directories 

       grep
          --pat -p STRING grep pattern 

    EXAMPLES
        perl $Script -e vim -p aa
        perl $Script --exts vim,pm --pat bb --dirs DIR
    };

    print $s . "\n";

    return $self;   
}

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my ($self) = @_;
    
    #$self->SUPER::init();
    
    my $h = {};
        
    hash_inject($self, $h);

    return $self;
}

# find + grep
sub find_grep {
    my ($self) = @_;

    my @exts = @{$self->{exts} || []};
    my @dirs = @{$self->{dirs} || []};
    my $pat  = $self->{pat} // '';

    return $self unless $pat && @exts && @dirs;

    my @glob  = map { "*.$_" } @exts;
    my @files = File::Find::Rule
           ->file()
           ->name(@glob)
           ->in(@dirs);

    my @r = fgrep { /$pat/ } @files;
    my @out;
    foreach my $rm (@r) {
       my $cnt = $rm->{count} // 0;
       next unless $cnt;

       my $m = $rm->{matches} // {};
       my $file = $rm->{filename} // '';
       my @nums = sort keys %$m;

       foreach my $num (@nums) {
          my $line = $m->{$num};

          my $str = sprintf(q{%s:%s:%s}, $file, $num, $line );
          print qq{$str};
       }

       1;
    }

    my @lines;
    foreach my $file (@files) {
        #my $cmd = qq{ grep -iRnH '$pat' $file };
        #my @out = qx{  };
        #print qq{$_} . "\n" for(@out);
        #system("$cmd");
        my ($r) = fgrep { /$pat/ } $file;
        my $m = $r->{matches} // {};

        next unless keys %$m;

        1;
    }
        $DB::single = 1;

    return $self;
}

sub run {
    my ($self) = @_;

    $self
        ->get_opt
        ->find_grep
        ;

    return $self;
}

1;
 

