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
# podtoc -- show outline of pods

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $inpod = undef;

$/ = '';

$inpod = 0;
while (<>) {
    print "$ARGV\n" if $. == 1;
    if ($inpod && /^=cut/) {
	$inpod = 0;
	next;
    } 

    if (! $inpod && /^=(?!cut)\w+/) {
	$inpod = 1;
    } 

    if ($inpod) {
	next unless /^=(?:head|item)/;
	s/=head(\d)/'    ' x ( $1 - 1 )/e;
	s/=item/     * /;
	s/\n+$/\n/;
	print;
    } 


} continue {

    if (eof) {
	$inpod = 0;
	close ARGV;
    }

} 

__END__

=head1 NAME

podtoc - show outline of pods

=head1 DESCRIPTION

This program shows the structure of one or more pod documents.

=head1 EXAMPLES

    $ podtoc `pmpath CGI`
     NAME
     SYNOPSIS
     ABSTRACT
     DESCRIPTION
	 PROGRAMMING STYLE
	 CALLING CGI.PM ROUTINES
	 *  1. Use another name for the argument, if one is available.  For
	    example, -value is an alias for -values.
	 *  2. Change the capitalization, e.g. -Values
    (etc)

=head1 SEE ALSO

pod2man(1), perlpod(1).

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
