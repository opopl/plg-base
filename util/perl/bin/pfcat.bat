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
# pfcat - cat out function definitions from perlfunc 
# 
# this is a command of its own so it can find the right version

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variable
my @options = ();	# list of podgrep options

@options = ();
while ($ARGV[0] =~ /^-/) {
    push @options, shift @ARGV;
} 

die "usage: $0 function\n" unless @ARGV;

system "$^X -S podgrep -h @options '@ARGV' `$^X -S podpath perlfunc`";
exit ($? != 0);

__END__

=head1 NAME

pfcat - grep out function definitions from perlfunc 

=head1 DESCRIPTION

This program uses I<podgrep> program to search your configuration's
L<perlfunc> for function definitions.  It honors a B<-f> flag to 
format through I<pod2text> and a B<-p> flag to send the output
through the pager.  (Actually, it just passes these to I<podgrep>.)

=head1 EXAMPLES

    $ pfcat seek
    (find all seek functions (including sysseek))

    $ pfcat -pf sprintf
    (sprintf function is formated and sent to pager)

    $ pfcat -f '\bint\b'
    /usr/local/devperl/lib/5.00554/pod/perlfunc.pod chunk 506
    int EXPR
    int

    Returns the integer portion of EXPR. If EXPR is omitted, uses
    `$_'. You should not use this for rounding, because it truncates
    towards `0', and because machine representations of floating point
    numbers can sometimes produce counterintuitive results. Usually
    `sprintf()' or `printf()', or the `POSIX::floor' or `POSIX::ceil'
    functions, would serve you better.

You can also run this using alternate perl binaries, like so:

    $ oldperl -S pfcat open
    ....

=head1 SEE ALSO

podgrep(1)

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
