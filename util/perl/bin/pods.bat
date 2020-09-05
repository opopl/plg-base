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
# pods - print out all pod paths
#
# this is a perl program not a shell script
# so that we can use the correct perl 

use strict;
use warnings;
use FindBin qw($Bin);

our $VERSION = '2.1.0';

system $^X, "-S", "$Bin/stdpods";
system $^X, "-S", "$Bin/pminst", "-l";

__END__

=head1 NAME

pods - print out all pod paths

=head1 DESCRIPTION

This program is a front end to print out the paths of all the standard
podpages and the modules.

=head1 SEE ALSO

faqpods(1), modpods(1), sitepods(1), podpath(1), pminst(1), and stdpod(1).

=head1 AUTHORS and COPYRIGHTS

Copyright (C) 1999 Tom Christiansen.

Copyright (C) 2006-2018 Mark Leighton Fisher.

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