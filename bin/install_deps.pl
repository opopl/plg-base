#vim:ts=2

use strict;
use warnings;
use File::Spec::Functions qw(catfile);

sub doPerl {
	my @mods_perl = qw(
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
		Class::Accessor::Installer
		XML::LibXML::Cache
		XML::LibXML::PrettyPrint
		XML::Hash::LX
	);
	
	for (@mods_perl){
		eval "require $_";
		if($@){
			print "$@\n";
			print "install $_ \n";
			system qq{cpan $_};
		}
	}
}

sub doPython2 {
}

sub doPython3 {

	my @packs;
	push @packs,
		'numpy',
		'sqlparse',
		;
	
	my $dir = $ENV{PYTHON3_PATH} || q{C:\Python_372_64bit};
	my $pip = catfile($dir, qw{Scripts pip.exe});
	
	for	(@packs){
		my $cmd = qq{cmd /c "$pip" install $_};
		system qq{$cmd};
	}
}

doPerl();
doPython2();
doPython3();
