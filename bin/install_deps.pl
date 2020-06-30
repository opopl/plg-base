#vim:ts=2

use strict;
use warnings;

my @mods = qw(
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
);

for (@mods){
	eval "require $_";
	if($@){
		print "$@\n";
		print "install $_ \n";
		system qq{cpan $_};
	}
}

my @cmds;
push @cmds,
	q{cmd /c "C:\Python_372_64bit\Scripts\pip.exe" install numpy},
	;

for	(@cmds){
	system qq{$_};
}

