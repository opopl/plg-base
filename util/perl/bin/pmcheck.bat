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
# pmcheck -- check that Perl is set up correctly for Perl modules

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $dir    = undef;     # directory in @INC
my $errors = 0;         # count of errors found

for $dir (@INC) { 
    if (!-e $dir) {
        print "'$dir' is in \@INC but does not exist\n";
        $errors++;
        next;
    }

    if (!-d $dir) {
        print "'$dir' is in \@INC but is not a directory\n";
        $errors++;
        next;
    }

    if (!-r $dir) {
        print "'$dir' is in \@INC but you cannot read it\n";
        $errors++;
        next;
    }
}

exit($errors != 0);

__END__

=head1 NAME

pmcheck - check that Perl is set up correctly for Perl modules

=head1 DESCRIPTION

pmcheck checks that Perl is correctly set up for Perl modules.
For now, pmcheck just verifies that the entries in @INC
are existing readable directories.

=head1 SEE ALSO

pmdirs(1), pmpath(1)

=head1 AUTHOR and COPYRIGHTS

Copyright (C) 2012-2014 Mark Leighton Fisher.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it
under the terms of either:
(a) the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or
(b) the Perl "Artistic License".
(This is the Perl 5 licensing scheme.)

__END__
:endofperl
