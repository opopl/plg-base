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
# modpods - print out all module pod paths
#
# this is a perl program not a shell script
# so that we can use the correct perl 

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

system $^X, "-S", "pminst", "-l";

__END__

=head1 NAME

modpods - print out paths for the standard modules

=head1 DESCRIPTION

This program outputs the paths to all installed modules on your systems.
This includes both the standard modules (which the I<stdpods> command
produces) and the site-specific ones (which the I<sitepods> command
produces).

This is just a front-end for calling I<pminst -l>, supplied
to make it more obvious what it does.  

=head1 EXAMPLE

This finds all the modules whose documentation mentions
destructors, and cats it out at you.

    $ podgrep -i destructor `modpods`

    =head1 /usr/local/devperl/lib/5.00554/i686-linux/DB_File.pm chunk 371

    Having read L<perltie> you will probably have already guessed that the
    error is caused by the extra copy of the tied object stored in C<$X>.
    If you haven't, then the problem boils down to the fact that the
    B<DB_File> destructor, DESTROY, will not be called until I<all>
    references to the tied object are destroyed. Both the tied variable,
    C<%x>, and C<$X> above hold a reference to the object. The call to
    untie() will destroy the first, but C<$X> still holds a valid
    reference, so the destructor will not get called and the database file
    F<tst.fil> will remain open. The fact that Berkeley DB then reports the
    attempt to open a database that is alreday open via the catch-all
    "Invalid argument" doesn't help.

    =head1 /usr/local/devperl/lib/5.00554/Tie/Array.pm chunk 40

    Normal object destructor method.

=head1 SEE ALSO

podgrep(1), modpods(1), pods(1), sitepods(1), podpath(1), and stdpod(1).

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
