package Base::App::Grep;

use strict;
use warnings;

use utf8;

binmode STDOUT,':encoding(utf8)';

use Base::Arg qw( hash_inject );
use Getopt::Long qw(GetOptions);
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath rmtree);

use Base::File::Grep qw(fgrep);
use Cwd qw(getcwd);

use File::Find::Rule;
use Base::DB qw(
    dbi_connect
    dbh_insert_hash
    dbh_do

    $DBH
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

        # files
        "files|f=s@",

        # (grep)pattern to grep
        "pat|p=s",

        "ignore_case|i",
    );
    
    unless( @ARGV ){ 
        $self->print_help;
        exit 0;
    }else{
        GetOptions(\%opt, @optstr);
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

sub print_help {
    my ($self) = @_;

    my $pack = __PACKAGE__;

    my $s = qq{

    USAGE
        perl $Script OPTIONS
    PACKAGES
        $pack - calling package

        Base::File::Grep - cloned from File::Grep 
    OPTIONS
       find
          @ --exts -e (STRING, comma-separated list) extensions 
          @ --dirs -d (STRING) directories 

       grep
          --pat -p STRING grep pattern 

       grep options
          --ignore_case -i 

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
    
    my $h = {
      'cache_dir' => catfile($ENV{HOME},qw( .cache base-grep )),
    };

    mkpath $h->{cache_dir} unless -d $h->{cache_dir};
        
    hash_inject($self, $h);

    $self->init_db;

    return $self;
}

sub init_db {
    my ($self) = @_;

    my $dbfile = catfile($ENV{HOME},qw( db fs.db ));
    my $dbh = $DBH = dbi_connect({ dbfile => $dbfile });

    my $q = qq{
        CREATE TABLE IF NOT EXISTS files (
           path TEXT NOT NULL UNIQUE
        );
    };
    
    my $ok = dbh_do({ q => $q });

    return $self;

}

# find + grep
sub find_grep {
    my ($self) = @_;

    my @exts = @{$self->{exts} || []};
    my @dirs = @{$self->{dirs} || []};
    my $pat  = $self->{pat} // '';

    push @dirs, getcwd() unless @dirs;

    return $self unless $pat && @exts;

    my @glob  = map { "*.$_" } @exts;
    my @files = File::Find::Rule
           ->file()
           ->name(@glob)
           ->in(@dirs);

    my @r;
    if ($self->{ignore_case}) {
      @r = fgrep { /$pat/i } @files;
    }else{
      @r = fgrep { /$pat/ } @files;
    }

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
 

