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
# pman -- show a module's man page

# ------ pragmas
use strict;
use warnings;
use pmtools;

our $VERSION = '2.1.0';

# ------ define variables
my $module;     # module name
my $pager;      # $ENV{PAGER} - pager program
my $path;       # path for pod2text

BEGIN { $^W = 1 }
BEGIN { die "usage: $0 module ...\n" unless @ARGV }

use FindBin qw($Bin);

unless ($pager = $ENV{PAGER}) {
    require Config;
    $pager = $Config::Config{"pager"} || "more";
} 

for $module (@ARGV) { 
    $module =~ s#::#/#gmsx;
    my $found = 0;
    my $iter = pmtools::new_pod_iterator($module);

    while (my $pod = $iter->()) {
        if (-s $pod) {
            $path = $pod;
            $found++;
            last;
        }
    }
    
    if (!$found) {
        next;
    } 
    system "$^X -S pod2text $path | $pager";
}

exit(0);

__END__

=head1 NAME

pman - show a module's man page

=head1 DESCRIPTION

Send a module's pod through pod2text and your pager.

This is mostly here for people too lazy to type

    $ pod2text `pmpath CGI` | $PAGER

=head1 EXAMPLES

    $ pman CGI
    $ pman Curses

Or running under different versions of Perl: 

    $ oldperl -S pman CGI
    $ filsperl -S pman Threads

=head1 SEE ALSO

pod2text(1), perlpod(1), pod2man(1), pod2html(1).

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
