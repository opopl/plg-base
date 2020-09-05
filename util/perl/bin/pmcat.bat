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
# pmcat -- page a module file

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $pager = undef;	# $ENV{PAGER} - output paging program

BEGIN { $^W = 1 }
BEGIN { die "usage: $0 module ...\n" unless @ARGV }

use FindBin qw($Bin);

unless ($pager = $ENV{PAGER}) {
    require Config;
    $pager = $Config::Config{"pager"} || "more";
} 

exec "$pager `$^X -S $Bin/pmpath @ARGV`";

__END__

=head1 NAME

pmcat - page through a module file

=head1 DESCRIPTION

Given a module name, figure out the path name and send
that to the user's pager.

    $ pmcat CGI

This works also on alternate installed versions of Perl:

    $ oldperl -S pmcat strict

    $ filsperl -S pmcat Threads

This command is mostly here for people too lazy to type

    $ more `pmpath CGI` 

=head1 SEE ALSO

pmpath(1)

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
