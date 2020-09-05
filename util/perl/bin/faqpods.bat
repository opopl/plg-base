@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!/usr/bin/env perl
#line 15
# faqpods - print out the paths to the faqs
# 
# this is a perl program not a shell script
# so that we can use the correct perl 

# ------ pragmas
use strict;
use warnings;

use Config;

our $VERSION = '2.2.0';

my $foundcore = 0;
open(PROG, "$^X -S basepods |") || die "can't fork: $!";
while (<PROG>) {
    if (/perlfaq/) {
        print $_;
        $foundcore = 1;
    }
}

unless ($foundcore) {
    my $lib = $Config{'vendorlib'};
    opendir(LIB, $lib) || die "$0: can't opendir $lib: $!\n";
    while ($_ = readdir(LIB)) {
        print "$lib/$_\n" if /perlfaq.*\.pod$/;
    }
} 

__END__

=head1 NAME

faqpods - print out pod paths for the standard perl faqs

=head1 DESCRIPTION

This program uses your configuration's C<installprivlib> directory
to look up the full paths to those pod pages.  Any files in that
directory whose names start in C<perlfaq> will be printed to the standard
output, one per line.  This is normally used in backticks to produce
a list of filenames for other commands.

=head1 EXAMPLES

    $ podgrep typeglob `faqpods`
    ....

You can also run this using alternate perl binaries, like so:

    $ podgrep -i thread `filsperl faqpods`
    ....

=head1 SEE ALSO

basepods(1), modpods(1), pods(1), sitepod(1), podpath(1), and stdpod(1).

=head1 AUTHORS and COPYRIGHTS

Copyright (C) 1999 Tom Christiansen.

Copyright (C) 2006-2014, 2018 Mark Leighton Fisher.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it
under the terms of either:
(a) the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or
(b) the Perl "Artistic License".
(This is the Perl 5 licensing scheme.)

Please note this is a change from the
original pmtools-1.00 (still available on CPAN),
as pmtools-1.00 were licensed only under the
Perl "Artistic License".

__END__
:endofperl
