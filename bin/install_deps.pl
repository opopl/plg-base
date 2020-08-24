#vim:ts=2

use strict;
use warnings;
use File::Spec::Functions qw(catfile);

my @mods_perl = qw(
   Class::Accessor::Installer
   Data::Miscellany
   Data::Table
   HTML::FormatText
   HTML::Strip
   HTML::Toc
   SQL::SplitStatement
   String::Escape
   String::Util
   Text::TabularDisplay
   URI::Simple
   URL::Normalize
   XML::Dumper
   XML::Hash::LX
   XML::LibXML::Cache
   XML::LibXML::PrettyPrint
);

# needed for repos_git p
push @mods_perl,
   qw(LaTeX::Table),
   qw(BibTeX::Parser),
   qw(Switch),
   qw(Directory::Iterator),
   qw(Text::Table),
   qw(ExtUtils::ModuleMaker),
   qw(Term::ShellUI),
   qw(List::Compare File::Util),
   ;

# needed for projs
push @mods_perl,
    qw(Capture::Tiny)
    ;

# for htmltool
push @mods_perl,qw(
   Exception::Base
   HTML::Encoding
   Text::Format
   Tk
   Tk::HistEntry
   Tk::HyperText
   XML::LibXML::Simple
);

my @packs_py;
push @packs_py,
    'numpy',
    'sqlparse',
    'tabulate',
    'peewee',
    ;

sub doPerl {

    for (@mods_perl){
        eval "require $_";
        if($@){
            print "$@\n";
            print "install $_ \n";
            system qq{cpan $_};
        }
    }
}

sub pip {
    my ($num) = @_;
    $num ||= 2;

    my $dir;
   
    if ($num == 2) {
        $dir = $ENV{PYTHON2_PATH} || q{C:\Python27};
    }elsif($num == 3){
        $dir = $ENV{PYTHON3_PATH} || q{C:\Python_372_64bit};
    }

    my $pip = catfile($dir, qw{Scripts pip.exe});
    return $pip;
}

sub doPython {
    my ($num) = @_;

    my $pip = pip($num);
    for (@packs_py){
        my $cmd = qq{cmd /c "$pip" install $_};
        system qq{$cmd};
    }
}

doPerl();
doPython(2);
doPython(3);
