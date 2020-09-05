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
# pmls -- show date stamp of module

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.1.0';

BEGIN { $^W = 1 }

# ------ define variable
my $module = undef;	# module name

use FindBin qw($Bin);

unless (@ARGV) {
    die "usage: $0 module ...\n";
} 
for $module (@ARGV) {
    if ( $^O eq "MSWin32" ) {
        my $path = `$^X -S $Bin/pmpath $module`;
        $path =~ s/\//\\/g;
        system "dir " . $path;
    } else {
        system "ls -l " . `$^X -S $Bin/pmpath $module`;
    }    
}

__END__

=head1 NAME

pmls - long list the module path

=head1 DESCRIPTION

This is mostly here for people too lazy to type

    $ ls -l `pmpath CGI` 

=head1 EXAMPLES

    $ pmls CGI
    -r--r--r--   1 root     root       190901 Dec  6 03:19
		/usr/local/devperl/lib/5.00554/CGI.pm


    $ oldperl -S pmls CGI
    -r--r--r--   1 root     root       186637 Sep 10 00:18 
		/usr/lib/perl5/CGI.pm

=head1 SEE ALSO

pmpath(1)

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
