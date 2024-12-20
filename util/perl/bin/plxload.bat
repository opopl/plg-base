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
# plxload -- show what files a perl program loads

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $filename = undef;	# program filename

BEGIN { $^W = 1 }
BEGIN { die "usage: $0 filename\n" unless @ARGV == 1 }

$filename = shift;

use FindBin qw($Bin);

exec "$^X -I$Bin -MDevel::Loaded -S -c $filename 2>/dev/null";

__END__

=head1 NAME

plxload - show what files a perl program loads at compile time

=head1 SYNOPSYS

    $ plxload

=head1 DESCRIPTION

This program is used to show what modules a program would load at
compile time via C<use>.  Because this installs an at-exit handler and
then uses Perl's B<-c> flag for compile only, it will not find modules
loaded at run-time.  Use the Devel::Loaded module for that.

=head1 EXAMPLES

    $ plxload perldoc
    /usr/local/devperl/lib/5.00554/Exporter.pm
    /usr/local/devperl/lib/5.00554/strict.pm
    /usr/local/devperl/lib/5.00554/vars.pm
    /usr/local/devperl/lib/5.00554/i686-linux/Config.pm
    /usr/local/devperl/lib/5.00554/Getopt/Std.pm

    $ plxload /usr/src/perl5.005_54/installhtml
    /usr/local/devperl/lib/5.00554/Carp.pm
    /usr/local/devperl/lib/5.00554/Exporter.pm
    /usr/local/devperl/lib/5.00554/auto/Getopt/Long/autosplit.ix
    /usr/local/devperl/lib/5.00554/strict.pm
    /usr/local/devperl/lib/5.00554/vars.pm
    /usr/local/devperl/lib/5.00554/Pod/Functions.pm
    /usr/local/devperl/lib/5.00554/Getopt/Long.pm
    /usr/local/devperl/lib/5.00554/i686-linux/Config.pm
    /usr/local/devperl/lib/5.00554/lib.pm
    /home/tchrist/perllib/Pod/Html.pm
    /usr/local/devperl/lib/5.00554/Cwd.pm
    /usr/local/devperl/lib/5.00554/AutoLoader.pm

=head1 SEE ALSO

L<Devel::Loaded> and pmload(1).

=head1 AUTHORS and COPYRIGHTS

Copyright (C) 1999 Tom Christiansen.

Copyright (C) 2006-2014 Mark Leighton Fisher.

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
